Function Get-KubePodMetric
    {
        <#
        .SYNOPSIS
            Retrieves live CPU and memory usage for one or more Kubernetes pods from the metrics API, either per pod or broken down per container.
            This is the KubePS equivalent of 'kubectl top pod' and requires metrics-server (metrics.k8s.io) to be installed in the cluster.

        .EXAMPLE
            Get-KubePodMetric -Namespace default
            # Lists CPU and memory usage for every pod in the default namespace.

        .EXAMPLE
            Get-KubePodMetric -Namespace default -Pod api -Containers
            # Shows per-container CPU and memory usage for pods matching api in the default namespace.

        .EXAMPLE
            Get-KubePodMetric -AllNamespaces | Sort-Object Memory -Descending | Select-Object -First 5
            # Finds the five pods using the most memory across every namespace.
        #>
        [CmdletBinding(DefaultParameterSetName='Default')]
        param(
            [Parameter(Mandatory=$False, Position = 0, HelpMessage = 'The pod name or regular expression to match.')]
            [String]$Pod,
            [Parameter(Mandatory=$False, Position = 2, HelpMessage = 'Output one row per container instead of per pod.')]
            [Switch]$Containers,
            [Parameter(Mandatory=$False, Position = 3, ParameterSetName='AllNamespaces', HelpMessage = 'Retrieve pod metrics from every namespace.')]
            [Switch]$AllNamespaces,
            [Parameter(Mandatory=$False, Position = 4, HelpMessage = 'Watch the metrics')]
            [Switch]$Watch,
            [Parameter(Mandatory=$False, Position = 5, HelpMessage = 'The number of seconds between refreshes when -Watch is used.')]
            [ValidateRange(0.1, 3600)]
            [Double]$RefreshSeconds = 0.5
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
                        HelpMessage      = 'The namespace to query. Required unless -AllNamespaces is used.'
                        Position         = 1
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

                If(-not $AllNamespaces -and [string]::IsNullOrWhiteSpace($Namespace))
                    {
                        Write-Error 'One of -Namespace or -AllNamespaces must be specified.' -Category InvalidArgument
                        Break
                    }
            }

        Process
            {
                $Params = @{
                    Pod = $Pod
                    Namespace = $Namespace
                    Containers = [bool]$Containers
                    AllNamespaces = [bool]$AllNamespaces
                }
                If($Watch)
                    {
                        $Scope = If($AllNamespaces) { 'all namespaces' } Else { "namespace '$Namespace'" }
                        Start-MetricWatcher -MetricCommand 'Get-PodMetrics' -MetricParameters $Params -Title "Pod metrics in $Scope" -RefreshSeconds $RefreshSeconds
                        Return
                    }
                $Output = Get-PodMetrics @Params
            }
        End
            {
                Return $Output
            }
    }
