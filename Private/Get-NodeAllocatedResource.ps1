Function Get-NodeAllocatedResource
    {
        <#
        .SYNOPSIS
            Retrieves allocated resources for a specific node in a Kubernetes cluster.
            This function retrieves allocated resources for a specific node in a Kubernetes cluster, including CPU and memory usage. It can output metrics for individual containers within the pods.

        .EXAMPLE
            # Retrieves allocated resources for the specified node and pods.
            Get-NodeAllocatedResource -Node $Node -Pods $Pods
        #>
        
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True)]
            [object[]]$Pods,
            [Parameter(Mandatory=$True)]
            [object]$Node
        )

        Begin
            {
                [System.Collections.Generic.List[object]]$Results = @()
                $Metrics = @(
                    'Requests',
                    'Limits'
                )
            }

        Process
            {
                $ResourceTotals = @{
                    Requests = @{}
                    Limits   = @{}
                }

                ForEach($PodItem in $Pods)
                    {
                        Write-Verbose "Getting Allocations from pod $($PodItem.metadata.Name)..."
                        ForEach($Container in $PodItem.Spec.Containers)
                            {
                                Write-Verbose "Getting Allocations from container $($Container.Name)..."
                                ForEach($Metric in $Metrics)
                                    {
                                        $Quantities = $Container.Resources.$Metric
                                        Write-Verbose "Metric for $Metric is '$Quantities'"
                                        If($Null -eq $Quantities)
                                            {
                                                Continue
                                            }

                                        ForEach($Resource in $Quantities.Keys)
                                            {
                                                Write-Verbose "Parsing value from $Resource key..."
                                                $ResourceTotals[$Metric][$Resource] = [decimal]$ResourceTotals[$Metric][$Resource] + (ConvertTo-KubePSResourceNumber $Quantities[$Resource].ToString())
                                            }
                                    }
                            }
                    }

                $Object = [PSCustomObject]@{
                    # PSTypeName = 'KubePS.NodeAllocatedResource'
                    Node = $PodItem.Spec.NodeName
                }

                ForEach($Resource in ($ResourceTotals.Requests.Keys + $ResourceTotals.Limits.Keys | Sort-Object -Unique)) 
                    {
                        Write-Verbose "Parsing $Resource"
                        ForEach($Metric in $Metrics)
                            {
                                Write-Verbose "Pasing $Metric"
                                $Value = [decimal]$ResourceTotals[$Metric][$Resource]
                                $NodeCapacity = ConvertTo-KubePSResourceNumber ([string]$Node.Status.Allocatable[$Resource])

                                $Percent = $Null
                                If($NodeCapacity -gt 0)
                                    {
                                        $Percent = [math]::Round(($Value / $NodeCapacity) * 100)
                                    }

                                Switch -regex ($Resource)
                                    {
                                        'cpu' { $DisplayValue = [math]::Round($Value * 1000) }
                                        'memory|ephemeral-storage|hugepages-.*' { $DisplayValue = [math]::Round($Value / 1MB, 2) }
                                        default { $DisplayValue = [string]$Value }
                                    }

                                $Object | Add-Member -MemberType NoteProperty -Name "$Resource$Metric" -Value $DisplayValue -Force
                                $Object | Add-Member -MemberType NoteProperty -Name "$Resource$($Metric)Percent" -Value $Percent -Force
                            }
                    }
                $Results.Add($Object)
            }

        End
            {
                Return $Results
            }
    }