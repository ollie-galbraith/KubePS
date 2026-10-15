Function Get-NodeMetrics
    {
        <#
        .SYNOPSIS
            Retrieves live CPU and memory usage for cluster nodes from the metrics API and calculates the percentage of each node's allocatable capacity in use.
            This helper is used by Get-KubeNodeMetric, both for one-off output and on each refresh when -Watch is specified.

        .EXAMPLE
            Get-NodeMetrics
            # Returns CPU and memory usage for every node.

        .EXAMPLE
            Get-NodeMetrics -Node 'worker-.*'
            # Returns usage only for nodes whose names match the regex pattern.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$False, Position = 0, HelpMessage = 'The node name or regular expression to match.')]
            [string]$Node
        )

        Try
            {
                Write-Verbose "Retrieving node metrics."
                $Metrics = [k8s.KubernetesMetricsExtensions]::GetKubernetesNodesMetricsAsync(
                    $Script:KubePSDirectClient         # Client
                ).GetAwaiter().GetResult().Items
            }
        Catch [k8s.Autorest.HttpOperationException]
            {
                If($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::NotFound)
                    {
                        Write-Error 'The metrics API (metrics.k8s.io) is not available. Is metrics-server installed?' -Category ResourceUnavailable
                        Return
                    }
                Throw
            }

        # Allocatable capacity is needed to express usage as a percentage, matching 'kubectl top node'.
        $Allocatable = @{}
        $NodeItems = [k8s.CoreV1OperationsExtensions]::ListNodeAsync($Script:KubePSDirectClient.CoreV1).GetAwaiter().GetResult().Items
        ForEach($NodeItem in $NodeItems)
            {
                $Allocatable[$NodeItem.Metadata.Name] = $NodeItem.Status.Allocatable
            }

        [System.Collections.Generic.List[object]]$Output = @()

        ForEach($NodeMetric in $Metrics)
            {
                If(([string]::IsNullOrEmpty($Node) -eq $False) -and ($NodeMetric.Metadata.Name -notmatch $Node))
                    {
                        Continue
                    }

                $Cpu = ConvertTo-KubePSResourceNumber -Quantity ([string]$NodeMetric.Usage['cpu'])
                $Memory = ConvertTo-KubePSResourceNumber -Quantity ([string]$NodeMetric.Usage['memory'])

                $CpuPercent = $null
                $MemoryPercent = $null
                $NodeAllocatable = $Allocatable[$NodeMetric.Metadata.Name]
                If($null -ne $NodeAllocatable)
                    {
                        $CpuAllocatable = ConvertTo-KubePSResourceNumber -Quantity ([string]$NodeAllocatable['cpu'])
                        $MemoryAllocatable = ConvertTo-KubePSResourceNumber -Quantity ([string]$NodeAllocatable['memory'])
                        If($CpuAllocatable -gt 0)
                            {
                                $CpuPercent = [Math]::Round($Cpu / $CpuAllocatable * 100, 2)
                            }
                        If($MemoryAllocatable -gt 0)
                            {
                                $MemoryPercent = [Math]::Round($Memory / $MemoryAllocatable * 100, 2)
                            }
                    }

                $Output.Add([PSCustomObject]@{
                    PSTypeName    = 'KubePS.NodeMetric'
                    Name          = $NodeMetric.Metadata.Name
                    Cpu           = $Cpu
                    CpuPercent    = $CpuPercent
                    Memory        = $Memory
                    MemoryPercent = $MemoryPercent
                    Timestamp     = $NodeMetric.Timestamp
                    Window        = $NodeMetric.Window
                })
            }

        Return $Output
    }
