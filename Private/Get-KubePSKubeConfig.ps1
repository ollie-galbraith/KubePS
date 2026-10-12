Function Get-KubePSKubeConfig
    {
        $ConfiguredPaths = [Environment]::GetEnvironmentVariable('KUBECONFIG')
        If([string]::IsNullOrWhiteSpace($ConfiguredPaths))
            {
                $ConfigPaths = @([k8s.KubernetesClientConfiguration]::KubeConfigDefaultLocation)
            }
        Else
            {
                $ConfigPaths = @($ConfiguredPaths.Split([IO.Path]::PathSeparator, [StringSplitOptions]::RemoveEmptyEntries))
            }

        $KubeConfigs = @($ConfigPaths | ForEach-Object {
            [k8s.KubernetesClientConfiguration]::LoadKubeConfig($_, $true)
        })
        If($KubeConfigs.Count -eq 0)
            {
                Throw 'No Kubernetes configuration files were found.'
            }

        $Configuration = $KubeConfigs[0]
        ForEach($AdditionalConfig in $KubeConfigs | Select-Object -Skip 1)
            {
                $ContextNames = @($Configuration.Contexts | ForEach-Object Name)
                $ClusterNames = @($Configuration.Clusters | ForEach-Object Name)
                $UserNames = @($Configuration.Users | ForEach-Object Name)
                $Configuration.Contexts = @($Configuration.Contexts) + @($AdditionalConfig.Contexts | Where-Object Name -NotIn $ContextNames)
                $Configuration.Clusters = @($Configuration.Clusters) + @($AdditionalConfig.Clusters | Where-Object Name -NotIn $ClusterNames)
                $Configuration.Users = @($Configuration.Users) + @($AdditionalConfig.Users | Where-Object Name -NotIn $UserNames)
                If([string]::IsNullOrWhiteSpace($Configuration.CurrentContext))
                    {
                        $Configuration.CurrentContext = $AdditionalConfig.CurrentContext
                    }
            }

        Return $Configuration
    }
