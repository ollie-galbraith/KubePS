Function Get-KubeConfig
    {
        <#
        .SYNOPSIS
            Loads and merges the active Kubernetes kubeconfig files into a single configuration object that KubePS uses for cluster operations.
            This helper checks the KUBECONFIG environment variable or the default kubeconfig location, reads each config file, and combines contexts, clusters, and users so commands like Set-Context and Get-Context can work against the same merged view of the cluster configuration.

        .EXAMPLE
            Get-KubePSKubeConfig
            # Returns the merged kubeconfig currently being used by KubePS.

        .EXAMPLE
            $Config = Get-KubePSKubeConfig
            $Config.CurrentContext
            # Displays the currently selected context after any merged kubeconfig files are read.

        .EXAMPLE
            $env:KUBECONFIG = "$HOME/.kube/config:$HOME/.kube/team-config"
            Get-KubePSKubeConfig
            # Loads both kubeconfig files and combines their contexts and users before selecting an active context.
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
