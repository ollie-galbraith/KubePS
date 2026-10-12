Function Get-NodeAllocatedResources
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
                        HelpMessage                     = 'The name of the node to retrieve allocated resources for.'
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
                $ResourceNameMap = @{
                    'cpu'               = 'CPU'
                    'memory'            = 'Memory'
                    'ephemeral-storage' = 'EphemeralStorage'
                }
            }
        Process
            {
                ForEach($NodeName in $DynamicParameterDictionary['Node'].Value) { $NodeNames.Add($NodeName) }
            }
        End
            {
                ForEach($NodeName in $NodeNames)
                    {
                        $NodeInfo = Get-NodeDescription -Node $NodeName | Select-Object -ExpandProperty AllocatedResources
                        ForEach($Metric in 'Requests', 'Limits')
                            {
                                $Row = [ordered]@{
                                    PSTypeName = 'KubePS.AllocatedResource'
                                    NodeName   = $NodeName
                                    Metric     = $Metric
                                }
                                ForEach($Resource in $NodeInfo)
                                    {
                                        $Cell = [pscustomobject]@{
                                            PSTypeName = 'KubePS.ResourceValue'
                                            Value      = $Resource.$Metric
                                            Percent    = $Resource."${Metric}Percent"
                                        }
                                        $Cell | Add-Member -MemberType ScriptMethod -Name ToString -Force -Value {
                                            If($null -ne $this.Percent -and $this.Percent -ne '')
                                                {
                                                    '{0} ({1}%)' -f $this.Value, $this.Percent
                                                }
                                            Else
                                                {
                                                    [string]$this.Value
                                                }
                                        }
                                        $PropertyName = $ResourceNameMap[$Resource.Resource]
                                        If(-not $PropertyName)
                                            {
                                                $PropertyName = ($Resource.Resource -replace '^hugepages', 'HugePages') -split '[-./]' |
                                                    ForEach-Object {
                                                        $_.Substring(0, 1).ToUpper() + $_.Substring(1)
                                                    }
                                                $PropertyName = -join $PropertyName
                                            }
                                        $Row[$PropertyName] = $Cell
                                    }
                                $Output.Add([pscustomobject]$Row)
                            }
                    }
                Return $Output
            }
    }