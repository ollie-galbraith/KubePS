Function Set-Context
    {
        [CmdletBinding()]
        param()

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Contexts = Get-Context

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
                        Get-KubePSClient | Out-Null
                    }
                Catch
                    {
                        $Script:KubePSContext = $PreviousContext
                        Throw
                    }
            }
    }