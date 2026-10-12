Function Get-KubePSClient
    {
        $ConfiguredPaths = [Environment]::GetEnvironmentVariable('KUBECONFIG')
        If([string]::IsNullOrWhiteSpace($ConfiguredPaths))
            {
                $ConfigPaths = @([k8s.KeubernetesClientConfiguration]::KubeConfigDefaultLocation)
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
                $KubeConfig = Get-KubePSKubeConfig
                $Configuration = [k8s.KubernetesClientConfiguration]::BuildConfigFromConfigObject($KubeConfig, $ContextStamp, $null)
            }
        $Script:KubePSDirectClient = [k8s.Kubernetes]::new($Configuration)
        $Script:KubePSDirectConfigStamp = $ConfigStamp
        $Script:KubePSDirectContextStamp = $ContextStamp
    }