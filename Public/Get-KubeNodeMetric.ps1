Function Get-KubeNodeMetric
    {
        <#
        .SYNOPSIS
            Retrieves live CPU and memory usage for cluster nodes from the metrics API, including the percentage of each node's allocatable capacity in use.
            This is the KubePS equivalent of 'kubectl top node' and requires metrics-server (metrics.k8s.io) to be installed in the cluster.

        .EXAMPLE
            Get-KubeNodeMetric
            # Lists CPU and memory usage for every node.

        .EXAMPLE
            Get-KubeNodeMetric -Node 'worker-.*' | Sort-Object CpuPercent -Descending
            # Shows usage for nodes matching worker-, busiest CPU first.

        .EXAMPLE
            Get-KubeNodeMetric -Watch -RefreshSeconds 2
            # Shows a live view of node usage in the alternate screen buffer, refreshing every two seconds until Ctrl+C is pressed.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$False, Position = 0, HelpMessage = 'The node name or regular expression to match.')]
            [String]$Node,
            [Parameter(Mandatory=$False, Position = 1, HelpMessage = 'Watch the metrics')]
            [Switch]$Watch,
            [Parameter(Mandatory=$False, Position = 2, HelpMessage = 'The number of seconds between refreshes when -Watch is used.')]
            [ValidateRange(0.1, 3600)]
            [Double]$RefreshSeconds = 0.5
        )

        $Params = @{
            Node = $Node
        }
        If($Watch)
            {
                Start-MetricWatcher -MetricCommand 'Get-NodeMetrics' -MetricParameters $Params -Title 'Node metrics' -RefreshSeconds $RefreshSeconds
                Return
            }
        Return Get-NodeMetrics @Params
    }
