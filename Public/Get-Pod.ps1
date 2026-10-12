Function Get-Pod
    {
        [CmdletBinding(DefaultParameterSetName='Default')]
        param(
            [Parameter(Mandatory = $False, Position = 0, HelpMessage = 'The pod name or regular expression to match.')]
            [string]$Pod,
            [Parameter(Mandatory = $False, Position = 1, HelpMessage = 'The label to filter pods by.')]
            [string]$Label,
            [Parameter(Mandatory = $False, Position = 2, HelpMessage = 'Output full pod information.')]
            [switch]$FullOutput,
            [Parameter(Mandatory = $False, Position = 3, ParameterSetName='AllNamespaces', HelpMessage = 'Retrieve pods from every namespace.')]
            [switch]$AllNamespaces
        )

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Namespaces = Get-Namespace

                $ParamList = @(
                    @{
                        ParameterName    = 'Namespace'
                        ParameterType    = ([string])
                        Default          = $Script:SelectedNamespace
                        Mandatory        = $False
                        ValidateSet      = [array]$Namespaces.Name
                        HelpMessage      = 'The namespace to query. Required unless -AllNamespaces is used.'
                        Position         = 1
                        ParameterSetName = 'Namespace'
                    }
                )

                ForEach($Param in $ParamList)
                    {
                        Add-DynamicParameter @NewDynamicParams @Param
                    }
                Return $DynamicParameterDictionary
            }
        
        Begin
            {
                [System.Collections.Generic.List[object]]$Output = @()
                $Namespace = $DynamicParameterDictionary['Namespace'].Value
            
                If((-not $AllNamespaces -and ([String]::IsNullOrEmpty($Label))) -and [string]::IsNullOrWhiteSpace($Namespace))
                    {
                        Write-Error 'One of -Namespace, -Label or -AllNamespaces must be specified.' -Category InvalidArgument
                        Break
                    }
            }
        
        Process
            {
                $PodRegexed = -not [string]::IsNullOrEmpty($Pod) -and
                    [System.Text.RegularExpressions.Regex]::Escape($Pod) -ne $Pod

                If(([string]::IsNullOrEmpty($Pod) -eq $False) -and ($PodRegexed -eq $False) -and ($AllNamespaces -eq $False))
                    {
                        Write-Verbose "Retrieving pod '$Pod' in namespace '$Namespace'."
                        Try
                            {
                                $Pods = @([k8s.CoreV1OperationsExtensions]::ReadNamespacedPodAsync(
                                    $Script:KubePSDirectClient.CoreV1, # Client
                                    $Pod,                              # Pod name
                                    $Namespace                         # Namespace
                                ).GetAwaiter().GetResult())
                            }
                        Catch [k8s.Autorest.HttpOperationException]
                            {
                                If($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::NotFound)
                                    {
                                        Write-Error "Pod '$Pod' was not found in namespace '$Namespace'." -Category ObjectNotFound
                                        Return
                                    }
                                Throw
                            }
                    }
                ElseIf($AllNamespaces -and ([string]::IsNullOrEmpty($Pod) -eq $False) -and ($PodRegexed -eq $False))
                    {
                        Write-Verbose "Retrieving pod '$Pod' in all namespaces"

                        $Pods = [k8s.CoreV1OperationsExtensions]::ListPodForAllNamespacesAsync(
                            $Script:KubePSDirectClient.CoreV1, # Client
                            $null,                             # allowWatchBookmarks
                            $null,                             # continueParameter
                            "metadata.name=$Pod"               # fieldSelector
                        ).GetAwaiter().GetResult().Items
                    }
                ElseIf($AllNamespaces -or ([String]::IsNullOrEmpty($Label) -eq $False))
                    {
                        Write-Verbose "Retrieving pods in all namespaces."
                        $Pods = [k8s.CoreV1OperationsExtensions]::ListPodForAllNamespacesAsync(
                            $Script:KubePSDirectClient.CoreV1,
                            $null,                             # allowWatchBookmarks
                            $null,                             # continueParameter
                            $null,                             # fieldSelector
                            $Label                             # labelSelector
                        ).GetAwaiter().GetResult().Items
                    }
                Else
                    {
                        Write-Verbose "Retrieving pods in namespace '$Namespace'."
                        $Pods = [k8s.CoreV1OperationsExtensions]::ListNamespacedPodAsync($Script:KubePSDirectClient.CoreV1, $Namespace).GetAwaiter().GetResult().Items
                    }

                ForEach($PodItem in $Pods)
                    {
                        If($FullOutput)
                            {
                                $Output.Add($PodItem)
                                Continue
                            }

                        If(([string]::IsNullOrEmpty($Pod) -eq $False) -and ($PodItem.Metadata.Name -notmatch $Pod))
                            {
                                continue
                            }

                        $ReadyCount = 0
                        $Restarts = 0
                        $Status = $PodItem.Status.Phase
                        ForEach($ContainerStatus in $PodItem.Status.ContainerStatuses)
                            {
                                If($ContainerStatus.Ready)
                                    {
                                        $ReadyCount++
                                    }

                                $Restarts += $ContainerStatus.RestartCount
                                If($ContainerStatus.State.Waiting.Reason)
                                    {
                                        $Status = $ContainerStatus.State.Waiting.Reason
                                    }
                                ElseIf($ContainerStatus.State.Terminated.Reason)
                                    {
                                        $Status = $ContainerStatus.State.Terminated.Reason
                                    }
                            }

                        ForEach($InitStatus in $PodItem.Status.InitContainerStatuses)
                            {
                                $Restarts += $InitStatus.RestartCount
                                If(-not $InitStatus.Ready -and $InitStatus.State.Waiting.Reason)
                                    {
                                        $Status = "Init:$($InitStatus.State.Waiting.Reason)"
                                    }
                            }

                        If($PodItem.Metadata.DeletionTimestamp)
                            {
                                $Status = 'Terminating'
                            }
                        
                        $Containers = $PodItem.Spec.Containers
                        $InitContainers = $PodItem.Spec.InitContainers

                        [System.Collections.Generic.List[object]]$Ports = @()

                        ForEach($Container in $Containers)
                            {
                                If($null -eq $Container.Ports)
                                    {
                                        continue
                                    }
                                ForEach($Port in $Container.Ports)
                                    {
                                        $Ports.Add([PSCustomObject]@{
                                            Port     = $Port.ContainerPort
                                            Protocol = $Port.Protocol
                                        })
                                    }
                            }

                        $IPAddress = $Null
                        If([string]::IsNullOrWhiteSpace($PodItem.Status.PodIP) -eq $False)
                            {
                                $IpAddress = [IPAddress]::Parse($PodItem.Status.PodIP)
                            }

                        $Object = [PSCustomObject]@{
                            PSTypeName     = 'KubePS.Pod'
                            Name           = $PodItem.Metadata.Name
                            Ready          = "$ReadyCount/$($Containers.Count)"
                            Status         = $Status
                            Restarts       = $Restarts
                            Age            = [DateTimeOffset]::UtcNow - [DateTimeOffset]$PodItem.Metadata.CreationTimestamp
                            IpAddress      = $ipAddress
                            Ports          = $Ports
                            Containers     = @($Containers | ForEach-Object {$_.Name})
                            InitContainers = @($InitContainers | ForEach-Object {$_.Name})
                        }

                        If($AllNamespaces -or ([String]::IsNullOrEmpty($Label) -eq $False))
                            {
                                $Object.PSObject.TypeNames.Insert(0, 'KubePS.Pod.AllNamespaces')
                                $Object | Add-Member -MemberType NoteProperty -Name 'Namespace' -Value $PodItem.Metadata.NamespaceProperty
                            }

                        $Output.Add($Object)
                    }
            }
        End
            {
                Return $Output
            }
    }