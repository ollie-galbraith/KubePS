Function Get-KubeNodeAllocatedResource
    {
        <#
        .SYNOPSIS
            Summarizes the CPU, memory, and other resource requests and limits currently allocated across selected cluster nodes.
            This command inspects node allocatable data alongside pod resource usage and returns a per-node breakdown showing requested and limited capacity by metric, including percentages relative to the node’s available resources.

        .EXAMPLE
            Get-KubeNodeAllocatedResources -Node worker-1
            # Returns the request and limit usage summary for the worker-1 node.

        .EXAMPLE
            Get-KubeNodeAllocatedResources -Node worker-1,worker-2
            # Produces a resource allocation summary for multiple nodes in a single call.

        .EXAMPLE
            Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty AllocatedResources
            # Shows the same underlying allocation data in the detailed node description object.
        #>
        [CmdletBinding()]
        param()

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Nodes = Get-KubeNode

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
                        $NodeInfo = Get-KubeNodeDescription -Node $NodeName | Select-Object -ExpandProperty AllocatedResources
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