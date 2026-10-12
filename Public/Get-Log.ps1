Function Get-Log
    {
        [CmdletBinding(DefaultParameterSetName = 'Default')]
        param(
            [Parameter(Mandatory = $False, ParameterSetName = 'Pod', Position = 1, HelpMessage = 'The pod to retrieve logs for.')]
            [string]$Pod,
            [Parameter(Mandatory = $False, ParameterSetName = 'Label', Position = 1, HelpMessage = 'The label to filter pods by.')]
            [string]$Label,

            [Parameter(Mandatory = $False, Position = 1, HelpMessage = 'The container to retrieve logs for.')]
            [string]$Container,
            [Parameter(Mandatory = $False, HelpMessage = 'Retrieve logs from the previous instance of the container.')]
            [switch]$Previous,
            [Parameter(Mandatory = $False, HelpMessage = 'The time duration to retrieve logs for. Example: 1h, 30m, 15s.')]
            [ValidatePattern('^\d+[smhd]$')]
            [String]$Since,
            [Parameter(Mandatory = $False, HelpMessage = 'The number of lines to retrieve from the end of the log.')]
            [int]$TailLines = $null,
            [Parameter(Mandatory = $False, HelpMessage = 'Output the logs with timestamps.')]
            [switch]$Timestamps,
            [Parameter(Mandatory = $False, HelpMessage = 'Follow the log output.')]
            [switch]$Follow
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
                        HelpMessage      = 'The namespace to set as the context for retrieving pod logs.'
                        Position         = 3
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
                $SinceSeconds = $null
                If([string]::IsNullOrEmpty($Since) -eq $False)
                    {
                        $SinceSeconds = ConvertTo-Seconds -Duration $Since
                    }
            }

        Process
            {
                $Namespace = $DynamicParameterDictionary['Namespace'].Value

                $GetPodParams = @{
                    FullOutput = $True
                }
                Switch($PSCmdlet.ParameterSetName)
                    {
                        'Pod'
                            {
                                If([string]::IsNullOrWhiteSpace($Namespace))
                                    {
                                        Write-Error 'Specify -Namespace or use Set-SelectedNamespace.' -Category InvalidArgument
                                        Return
                                    }

                                $GetPodParams['Pod'] = $Pod
                                $GetPodParams['Namespace'] = $Namespace
                            }
                        'Label'
                            {
                                If([string]::IsNullOrWhiteSpace($Namespace) -eq $False)
                                    {
                                        $GetPodParams['Namespace'] = $Namespace
                                    }
                                $GetPodParams['Label'] = $Label
                            }
                    }

                Try
                    {
                        $PodItems = @(Get-Pod @GetPodParams)
                    }
                Catch
                    {
                        Write-Error "Failed to retrieve pods: $($_.Exception.Message)" -Category InvalidOperation
                        Return
                    }

                If($PodItems.Count -eq 0)
                    {
                        Write-Error 'No pods found matching the specified criteria.' -Category ObjectNotFound
                        Return
                    }

                ForEach($PodItem in $PodItems)
                    {
                        $PodName = $PodItem.Metadata.Name
                        $PodNamespace = $PodItem.Metadata.NamespaceProperty
                        If([string]::IsNullOrWhiteSpace($PodNamespace))
                            {
                                $PodNamespace = $Namespace
                            }

                        $Containers = @($PodItem.Spec.Containers | ForEach-Object Name)
                        If([String]::IsNullOrEmpty($Container) -eq $False)
                            {
                                If(-not $Containers.Contains($Container))
                                    {
                                        Write-Error "The specified container '$Container' does not exist in pod '$PodName'." -Category InvalidArgument
                                        Continue
                                    }
                                $Containers = @($Container)
                            }

                        ForEach($ContainerName in $Containers)
                            {
                                $TaillinesParameter = If($TailLines -eq 0) { [System.Type]::Missing } Else { [int]$TailLines }

                                $LogStreamArguments = [object[]]@(
                                    $Script:KubePSDirectClient.CoreV1,         # Client
                                    [string]$PodName,                          # name
                                    [string]$PodNamespace,                     # namespace
                                    [string]$ContainerName,                    # container
                                    [bool]$Follow,                             # follow
                                    $null,                                     # insecureSkipTLSVerifyBackend
                                    $null,                                     # limitBytes
                                    $null,                                     # pretty
                                    [bool]$Previous,                           # previous
                                    $SinceSeconds,                             # sinceSeconds
                                    [System.Type]::Missing,                    # stream
                                    $TaillinesParameter,                       # tailLines
                                    [bool]$Timestamps,                         # timestamps
                                    [System.Threading.CancellationToken]::None # cancellationToken
                                )

                                $Method = [k8s.CoreV1OperationsExtensions].GetMethod('ReadNamespacedPodLogAsync')
                                $LogStream = $Method.Invoke($null, $LogStreamArguments).GetAwaiter().GetResult()

                                If($null -eq $LogStream)
                                    {
                                        Write-Verbose "No log stream available for pod '$PodName' in namespace '$PodNamespace'"
                                        Continue
                                    }

                                $Reader = [System.IO.StreamReader]::new($LogStream)
                                Try
                                    {
                                        If($Follow)
                                            {
                                                Start-LogStreamer -LogStream $Reader
                                            }
                                        Else
                                            {
                                                $Reader.ReadToEnd()
                                            }
                                    }
                                Finally
                                    {
                                        $Reader.Dispose()
                                        $LogStream.Dispose()
                                    }
                            }
                    }
            }
    }