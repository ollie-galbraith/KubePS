Function Get-NodeNonTerminatedPod
    {
        <#

        .SYNOPSIS
            Retrieves non-terminated pods for a specific node in a Kubernetes cluster.
            This function retrieves non-terminated pods for a specific node in a Kubernetes cluster, including their resource requests and limits. It can output metrics for individual containers within the pods.

        .EXAMPLE
            # Retrieves non-terminated pods for the specified node and pods.
            Get-NodeNonTerminatedPod -Node $Node -Pods $Pods
        #>
        
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$False)]
            [object[]]$Pods,
            [Parameter(Mandatory=$True)]
            [object]$Node
        )
        
        Begin
            {
                [System.Collections.Generic.List[object]]$Results = @()
            }

        Process
            {
                ForEach($PodItem in $Pods)
                    {
                        $PodResources = @{
                            Requests = @{}
                            Limits = @{}
                        }

                        $Metrics = @(
                            'Requests',
                            'Limits'
                        )

                        ForEach($Container in $PodItem.Spec.Containers)
                            {
                                ForEach($Metric in $Metrics)
                                    {
                                        $Quantities = $Container.Resources.$Metric
                                        If($Null -eq $Quantities)
                                            {
                                                Continue
                                            }
                                        
                                        ForEach($Resource in $Quantities.Keys)
                                            {
                                                $Value = [string]$Quantities[$Resource]
                                                $PodResources[$Metric][$Resource]   = [decimal]$PodResources[$Metric][$Resource] + (ConvertTo-KubePSResourceNumber $Value)
                                            }
                                    }
                                
                                $Object = [PSCustomObject]@{
                                    PSTypeName = 'KubePS.Node.NonTerminatedPods'
                                    Node       = $PodItem.Spec.nodeName
                                    Namespace  = $PodItem.Metadata.NamespaceProperty
                                    Name       = $PodItem.Metadata.Name
                                    Age        = [DateTimeOffset]::UtcNow - [DateTimeOffset]$PodItem.Metadata.CreationTimestamp
                                }

                                ForEach($Resource in 'Cpu', 'Memory')
                                    {
                                        ForEach($Metric in $Metrics)
                                            {
                                                $Value = [decimal]$PodResources[$Metric][$Resource]
                                                $CapacityValue = ConvertTo-KubePSResourceNumber ([string]$Node.Status.Allocatable[$Resource.ToLowerInvariant()])

                                                $Percent = $Null
                                                $DisplayValue = $Null
                                                If($CapacityValue -gt 0)
                                                    {
                                                        $Percent = [math]::Round(($Value / $CapacityValue) * 100, 2)
                                                    }
                                                If($Value -ne 0)
                                                    {
                                                        If($Resource -eq 'Cpu')
                                                            {
                                                                $DisplayValue = [math]::Round($Value * 1000)
                                                            }
                                                        ElseIf($Resource -eq 'Memory')
                                                            {
                                                                $DisplayValue = [math]::Round($Value / 1MB, 2)
                                                            }
                                                    }

                                                $Object | Add-Member -MemberType NoteProperty -Name "${Resource}${Metric}" -Value $DisplayValue -Force
                                                $Object | Add-Member -MemberType NoteProperty -Name "${Resource}${Metric}%" -Value $Percent -Force
                                            }
                                    }

                                $Results.Add($Object)
                            }
                    }
            }
        End
            {
                Return $Results
            }
    }