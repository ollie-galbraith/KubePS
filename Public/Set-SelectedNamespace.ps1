Function Set-SelectedNamespace
    {
        <#
        .SYNOPSIS
            Sets the default Kubernetes namespace for the current session.
            This function allows you to set the default Kubernetes namespace for the current session.

        .EXAMPLE
            Set-SelectedNamespace -Namespace "my-namespace"
        #>
        
        [CmdletBinding()]
        param()

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Namespaces = Get-Namespace

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