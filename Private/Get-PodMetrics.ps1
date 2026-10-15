Function Get-PodMetrics
    {
        <#
        .SYNOPSIS
            Retrieves metrics for pods in a Kubernetes cluster.
            This function retrieves metrics for pods in a Kubernetes cluster, including CPU and memory usage. It can retrieve metrics for all namespaces or a specific namespace, and can output metrics for individual containers within the pods.

        .EXAMPLE
            # Retrieves metrics for all pods in the 'default' namespace.
            Get-PodMetrics -Namespace 'default'
        #>
        
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$False, Position = 0, HelpMessage = 'The pod name or regular expression to match.')]
            [string]$Pod,
            [Parameter(Mandatory=$False, Position = 1, HelpMessage = 'The namespace to query. Required unless -AllNamespaces is used.')]
            [string]$Namespace = $Script:SelectedNamespace,
            [Parameter(Mandatory=$False, Position = 2, HelpMessage = 'Output one row per container instead of per pod.')]
            [switch]$Containers,
            [Parameter(Mandatory=$False, Position = 3, ParameterSetName='AllNamespaces', HelpMessage = 'Retrieve pod metrics from every namespace.')]
            [switch]$AllNamespaces
        )

        Try
            {
                If($AllNamespaces)
                    {
                        Write-Verbose "Retrieving pod metrics in all namespaces."
                        $Metrics = [k8s.KubernetesMetricsExtensions]::GetKubernetesPodsMetricsAsync(
                            $Script:KubePSDirectClient         # Client
                        ).GetAwaiter().GetResult().Items
                    }
                Else
                    {
                        Write-Verbose "Retrieving pod metrics in namespace '$Namespace'."
                        $Metrics = [k8s.KubernetesMetricsExtensions]::GetKubernetesPodsMetricsByNamespaceAsync(
                            $Script:KubePSDirectClient,        # Client
                            $Namespace                         # Namespace
                        ).GetAwaiter().GetResult().Items
                    }
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

        [System.Collections.Generic.List[object]]$Output = @()

        ForEach($PodMetric in $Metrics)
            {
                If(([string]::IsNullOrEmpty($Pod) -eq $False) -and ($PodMetric.Metadata.Name -notmatch $Pod))
                    {
                        Continue
                    }

                [System.Collections.Generic.List[object]]$ContainerMetrics = @()
                $CpuTotal = [decimal]0
                $MemoryTotal = [decimal]0

                ForEach($Container in $PodMetric.Containers)
                    {
                        $Cpu = ConvertTo-KubePSResourceNumber -Quantity ([string]$Container.Usage['cpu'])
                        $Memory = ConvertTo-KubePSResourceNumber -Quantity ([string]$Container.Usage['memory'])
                        $CpuTotal += $Cpu
                        $MemoryTotal += $Memory

                        $ContainerMetrics.Add([PSCustomObject]@{
                            PSTypeName = 'KubePS.PodMetric.Container'
                            Namespace  = $PodMetric.Metadata.NamespaceProperty
                            Pod        = $PodMetric.Metadata.Name
                            Name       = $Container.Name
                            Cpu        = $Cpu
                            Memory     = $Memory
                        })
                    }

                If($Containers)
                    {
                        ForEach($ContainerMetric in $ContainerMetrics)
                            {
                                $Output.Add($ContainerMetric)
                            }
                        Continue
                    }

                $Output.Add([PSCustomObject]@{
                    PSTypeName = 'KubePS.PodMetric'
                    Namespace  = $PodMetric.Metadata.NamespaceProperty
                    Name       = $PodMetric.Metadata.Name
                    Cpu        = $CpuTotal
                    Memory     = $MemoryTotal
                    Timestamp  = $PodMetric.Timestamp
                    Window     = $PodMetric.Window
                    Containers = $ContainerMetrics
                })
            }

        Return $Output
    }