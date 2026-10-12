Function Get-NodePods
    {
        [CmdletBinding()]
        param()

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Nodes = Get-Nodes

                $ParamList = @(
                    @{
                        ParameterName                   = 'Node'
                        ParameterType                   = ([string[]])
                        Mandatory                       = $True
                        ValidateSet                     = [array]$Nodes.Name
                        Alias                           = 'Name'
                        ValueFromPipeline               = $True
                        ValueFromPipelineByPropertyName = $True
                        HelpMessage                     = 'The name of the node to retrieve non-terminated pods for.'
                        Position                        = 0
                        ParameterSetName                = 'Node'
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
                [System.Collections.Generic.List[string]]$NodeNames = @()
                [System.Collections.Generic.List[object]]$Output = @()
            }
        Process
            {
                ForEach($NodeName in $DynamicParameterDictionary['Node'].Value) { $NodeNames.Add($NodeName) }
            }
        End
            {
                ForEach($NodeName in $NodeNames)
                    {
                        $NodePods = Get-NodeDescription -Node $NodeName | Select-Object -ExpandProperty NonTerminatedPods
                        ForEach($Pod in $NodePods) { $Output.Add($Pod) }
                    }
                Return $Output
            }
    }