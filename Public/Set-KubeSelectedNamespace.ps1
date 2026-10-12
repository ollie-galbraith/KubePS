Function Set-KubeSelectedNamespace
    {
        <#
        .SYNOPSIS
            Sets the default namespace used by KubePS for commands that accept a namespace implicitly, making the current session operate within a single target namespace by default.
            This command updates the module-scoped selected namespace value and is used by commands such as Get-Pod, Get-Deployment, and Get-Log when no explicit namespace is supplied.

        .EXAMPLE
            Set-KubeSelectedNamespace -Namespace default
            # Uses the default namespace for later calls that do not specify -Namespace.

        .EXAMPLE
            Set-KubeSelectedNamespace -Namespace kube-system
            Get-KubePod
            # Lists pods from kube-system without repeating -Namespace kube-system each time.

        .EXAMPLE
            Get-KubeSelectedNamespace
            # Confirms which namespace is currently selected for the session.
        #>
        
        [CmdletBinding()]
        param()

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
                        Mandatory        = $true
                        ValidateSet      = [array]$Namespaces.Name
                        HelpMessage      = 'The Kubernetes namespace to set as default'
                        Position         = 1
                        ParameterSetName = 'Namespace'
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
                $Script:SelectedNamespace = $DynamicParameterDictionary['Namespace'].Value
            }
    }