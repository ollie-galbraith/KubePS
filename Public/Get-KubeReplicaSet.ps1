Function Get-KubeReplicaSet
    {
        <#
        .SYNOPSIS
            Lists replica sets in a namespace and optionally narrows the output to a specific name or regex pattern so deployment health and rollout state can be inspected quickly.
            This command provides the desired, current, and ready replica counts for each replica set, which helps operators monitor deployment behavior and identify under-replicated workloads.

        .EXAMPLE
            Get-KubeReplicaSet -Namespace default
            # Lists all replica sets in the default namespace.

        .EXAMPLE
            Get-KubeReplicaSet -Namespace default -ReplicaSet api
            # Shows only the replica set whose name matches api.

        .EXAMPLE
            Get-KubeReplicaSet -Namespace default -All
            # Includes replica sets with zero desired replicas so you can see inactive or scaled-down workloads.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$false, Position = 0, HelpMessage = 'The replica set name or regular expression to match.')]
            [string]$ReplicaSet,
            [Parameter(Mandatory=$false, HelpMessage = 'Include replica sets with zero desired replicas.')]
            [switch]$All
        )

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Namespaces = Get-KubeNamespace

                $ParamList = @(
                    @{
                        ParameterName    = 'Namespace'
                        ParameterType    = ([string])
                        DefaultValue     = $Script:SelectedNamespace
                        Mandatory        = $False
                        ValidateSet      = [array]$Namespaces.Name
                        HelpMessage      = 'The namespace to set as the context for retrieving deployments.'
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
                If([string]::IsNullOrWhiteSpace($Namespace))
                    {
                        Write-Error 'Specify -Namespace or use Set-SelectedNamespace.' -Category InvalidArgument
                        Return
                    }
                $ReplicaSetRegexed = -not [string]::IsNullOrEmpty($ReplicaSet) -and [System.Text.RegularExpressions.Regex]::Escape($ReplicaSet) -ne $ReplicaSet
            }

        Process
            {
                $ReplicaSets = [k8s.AppsV1OperationsExtensions]::ListNamespacedReplicaSetAsync($Script:KubePSDirectClient.AppsV1, $Namespace).GetAwaiter().GetResult().Items
                ForEach($ReplicaSetItem in $ReplicaSets)
                    {
                        If(([string]::IsNullOrEmpty($ReplicaSet) -eq $False) -and ($ReplicaSetRegexed -eq $False) -and ($ReplicaSetItem.Metadata.Name -ne $ReplicaSet))
                            {
                                Continue
                            }
                        If(($All -eq $false) -and ($ReplicaSetItem.Spec.Replicas -eq 0))
                            {
                                Continue
                            }

                        $Output.Add([pscustomobject]@{
                            PSTypeName = 'KubePS.ReplicaSet'
                            Name       = $ReplicaSetItem.Metadata.Name
                            Desired    = $ReplicaSetItem.Spec.Replicas
                            Current    = $ReplicaSetItem.Status.Replicas
                            Ready      = If($ReplicaSetItem.Status.AvailableReplicas) { [int]$ReplicaSetItem.Status.AvailableReplicas } Else { 0 }
                            Age        = [DateTimeOffset]::UtcNow - [DateTimeOffset]$ReplicaSetItem.Metadata.CreationTimestamp
                        })
                    }
            }

        End
            {
                If($ReplicaSetRegexed)
                    {
                        Return $Output | Where-Object Name -Match $ReplicaSet
                    }
                Return $Output
            }
    }