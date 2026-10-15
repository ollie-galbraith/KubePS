Function Get-KubeClient
    {
        <#
        .SYNOPSIS
            Builds and caches the Kubernetes .NET client used by the module, reusing it when the kubeconfig or selected context has not changed.
            This helper resolves the correct config source, rebuilds the client when needed, and ensures later commands call the same authenticated cluster client without repeatedly creating a new connection.

        .EXAMPLE
            Get-KubeClient
            # Creates the Kubernetes client using the selected context and current kubeconfig.

        .EXAMPLE
            Set-KubeContext -Context 'production'
            Get-KubeClient
            # Rebuilds the client after switching to a different cluster context.

        .EXAMPLE
            $Client = Get-KubeClient
            $Client.CoreV1.ListNamespaceAsync($null)
            # Gets the cached Kubernetes client object for lower-level API calls.
        #>
        $ConfiguredPaths = [Environment]::GetEnvironmentVariable('KUBECONFIG')
        If([string]::IsNullOrWhiteSpace($ConfiguredPaths))
            {
                $ConfigPaths = @([k8s.KubernetesClientConfiguration]::KubeConfigDefaultLocation)
            }
        Else
            {
                $ConfigPaths = @($ConfiguredPaths.Split([IO.Path]::PathSeparator, [StringSplitOptions]::RemoveEmptyEntries))
            }

        $Timestamps = foreach ($Path in $ConfigPaths) {
            if (Test-Path -LiteralPath $Path) {
                (Get-Item -LiteralPath $Path).LastWriteTimeUtc.Ticks
            }
            else {
                'missing'
            }
        }
        $ConfigStamp = $Timestamps -join '|'

        # Rebuild after kubeconfig changes, including changes made by Set-Context.
        $ContextStamp = [string]$Script:KubePSContext
        If($null -ne $Script:KubePSDirectClient -and $Script:KubePSDirectConfigStamp -eq $ConfigStamp -and $Script:KubePSDirectContextStamp -eq $ContextStamp)
            {
                Return $Script:KubePSDirectClient
            }

        If($null -ne $Script:KubePSDirectClient)
            {
                $Script:KubePSDirectClient.Dispose()
            }

        If([string]::IsNullOrWhiteSpace($ContextStamp))
            {
                $Configuration = [k8s.KubernetesClientConfiguration]::BuildDefaultConfig()
            }
        Else
            {
                $KubeConfig = Get-KubeConfig
                $Configuration = [k8s.KubernetesClientConfiguration]::BuildConfigFromConfigObject($KubeConfig, $ContextStamp, $null)
            }
        $Script:KubePSDirectClient = [k8s.Kubernetes]::new($Configuration)
        $Script:KubePSDirectConfigStamp = $ConfigStamp
        $Script:KubePSDirectContextStamp = $ContextStamp
    }