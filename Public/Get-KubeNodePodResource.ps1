Function Get-KubeNodePodResource
    {
        <#
        .SYNOPSIS
            Lists the non-terminated pods running on one or more nodes so operators can quickly correlate a node with the workloads scheduled on it.
            This helper wraps the detailed node description objects and returns only the pod inventory for the selected node names, which is useful for troubleshooting scheduling, evictions, and workload placement.

        .EXAMPLE
            Get-KubeNodePods -Node worker-1
            # Lists every non-terminated pod currently assigned to worker-1.

        .EXAMPLE
            Get-KubeNodePods -Node worker-1,worker-2 | Select-Object Name, Namespace, Status
            # Shows a concise list of pods across multiple nodes with key fields.

        .EXAMPLE
            Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty NonTerminatedPods
            # Retrieves the same workload detail from the full node description object.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$False)]
            [string[]]$Pod
        )

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
                ForEach($NodeName in $DynamicParameterDictionary['Node'].Value)
                    {
                        $NodeNames.Add($NodeName)
                    }
            }
        End
            {
                $NodePods = Get-KubeNodeDescription -Node $NodeName | Select-Object -ExpandProperty NonTerminatedPods
                ForEach($NodePod in $NodePods)
                    {
                        If($Pod.Count -eq 0)
                            {
                                $Output.Add($NodePod)
                                Continue
                            }

                        ForEach($RequestedPod in $Pod)
                            {
                                If($NodePod.Name -match $RequestedPod)
                                    {
                                        $Output.Add($NodePod)
                                    }
                            }
                    }

                Return $Output
            }
    }