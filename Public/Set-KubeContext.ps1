Function Set-KubeContext
    {
        <#
        .SYNOPSIS
            Selects a Kubernetes context for the active KubePS session and rebuilds the cached client so subsequent commands target the chosen cluster.
            This command uses the merged kubeconfig data and validates the requested context name before updating the session state and refreshing the direct Kubernetes client connection.

        .EXAMPLE
            Set-KubeContext -Context default
            # Switches KubePS to the default cluster context.

        .EXAMPLE
            Get-KubeContext -Current
            # Verifies the cluster currently selected by KubePS after switching contexts.

        .EXAMPLE
            Set-KubeContext -Context 'prod-cluster'
            Get-KubePod -Namespace default
            # Switches to the production cluster and immediately queries its pods.
        #>
        [CmdletBinding()]
        param()

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Contexts = Get-KubeContext

                $ParamList = @(
                    @{
                        ParameterName    = 'Context'
                        ParameterType    = ([string])
                        Mandatory        = $true
                        ValidateSet      = [array]$Contexts
                        HelpMessage      = 'The Kubernetes context to set as default'
                        Position         = 1
                        ParameterSetName = 'Context'
                    }
                )

                ForEach($Param in $ParamList)
                    {
                        Add-DynamicParameter @NewDynamicParams @Param
                    }
                Return $DynamicParameterDictionary
            }

        Process
            {
                $PreviousContext = $Script:KubePSContext
                $Script:KubePSContext = $DynamicParameterDictionary['Context'].Value
                Try
                    {
                        Get-KubeClient | Out-Null
                    }
                Catch
                    {
                        $Script:KubePSContext = $PreviousContext
                        Throw
                    }
            }
    }