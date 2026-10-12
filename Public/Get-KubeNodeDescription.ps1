Function Get-KubeNodeDescription
    {
        <#
        .SYNOPSIS
            Returns a rich description of one or more Kubernetes nodes, including labels, taints, conditions, addresses, system info, allocated resources, and the non-terminated pods currently running on each node.
            This command is the detailed node inspection tool in KubePS and is used by other node-oriented commands to gather capacity and workload information before summarizing it for users.

        .EXAMPLE
            Get-KubeNodeDescription -Node worker-1
            # Returns the full metadata and scheduling information for worker-1.

        .EXAMPLE
            Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty Conditions
            # Lists the current readiness, memory pressure, disk pressure, and PID pressure conditions for the node.

        .EXAMPLE
            Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty AllocatedResources
            # Displays how much CPU and memory requests/limits are currently used by workloads on that node.
        #>
        [CmdletBinding()]
        param()

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Nodes = Get-KubeNodes

                $ParamList = @(
                    @{
                        ParameterName                   = 'Node'
                        ParameterType                   = ([string[]])
                        Mandatory                       = $True
                        ValidateSet                     = [array]$Nodes.Name
                        Alias                           = 'Name'
                        ValueFromPipeline               = $True
                        ValueFromPipelineByPropertyName = $True
                        HelpMessage                     = 'The node to describe'
                        Position                        = 1
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
                [System.Collections.Generic.List[object]]$NodeNames = @()
            }
        Process
            {
                $NodeValues = $DynamicParameterDictionary['Node'].Value
                ForEach($NodeName in $NodeValues) { $NodeNames.Add($NodeName) }
            }
        End
            {
                ForEach($NodeName in $NodeNames)
                    {
                        $NodeItem = [k8s.CoreV1OperationsExtensions]::ReadNodeAsync(
                            $Script:KubePSDirectClient.CoreV1,
                            $NodeName
                        ).GetAwaiter().GetResult()
                        $Pods = [k8s.CoreV1OperationsExtensions]::ListPodForAllNamespacesAsync(
                            $Script:KubePSDirectClient.CoreV1,
                            $null,
                            $null,
                            "spec.nodeName=$NodeName"
                        ).GetAwaiter().GetResult().Items | Where-Object { $_.Status.Phase -notin @('Succeeded', 'Failed') }

                        $Capacity    = [ordered]@{}
                        $Allocatable = [ordered]@{}
                        ForEach($Resource in $NodeItem.Status.Capacity.Keys)
                            {
                                $Capacity[$Resource] = [string]$NodeItem.Status.Capacity[$Resource]
                            }
                        ForEach($Resource in $NodeItem.Status.Allocatable.Keys)
                            {
                                $Allocatable[$Resource] = [string]$NodeItem.Status.Allocatable[$Resource]
                            }

                        $ResourceTotals = @{ Requests = @{}; Limits = @{} }
                        $NonTerminatedPods = foreach ($PodItem in $Pods) {
                            $PodResources = @{ Requests = @{}; Limits = @{} }
                            ForEach($Container in $PodItem.Spec.Containers)
                                {
                                    ForEach($Metric in 'Requests', 'Limits')
                                        {
                                            $Quantities = $Container.Resources.$Metric
                                            If($null -eq $Quantities)
                                                {
                                                    Continue
                                                }
                                            ForEach($Resource in $Quantities.Keys)
                                                {
                                                    $Value                              = [string]$Quantities[$Resource]
                                                    $PodResources[$Metric][$Resource]   = [decimal]$PodResources[$Metric][$Resource] + (ConvertTo-KubePSResourceNumber $Value)
                                                    $ResourceTotals[$Metric][$Resource] = [decimal]$ResourceTotals[$Metric][$Resource] + (ConvertTo-KubePSResourceNumber $Value)
                                                }
                                        }
                                }

                            $Row = [ordered]@{
                                Namespace = $PodItem.Metadata.NamespaceProperty
                                Name = $PodItem.Metadata.Name 
                            }

                            ForEach($Resource in @('cpu', 'memory'))
                                {
                                    $PropertyName = If($Resource -eq 'cpu') { 'Cpu' } Else { 'Memory' }
                                    ForEach($Metric in 'Requests', 'Limits')
                                        {
                                            $Value                                  = [decimal]$PodResources[$Metric][$Resource]
                                            $CapacityValue                          = ConvertTo-KubePSResourceNumber ([string]$NodeItem.Status.Allocatable[$Resource])
                                            $Percent                                = If($CapacityValue -gt 0) { [math]::Round(($Value / $CapacityValue) * 100) } Else { $null }
                                            $DisplayValue                           = If($Value -eq 0) { $null } ElseIf($Resource -eq 'cpu') { "$([math]::Round($Value * 1000))m" } Else { "$([math]::Round($Value / 1MB, 2))Mi" }
                                            $Row["${PropertyName}${Metric}"]        = $DisplayValue
                                            $Row["${PropertyName}${Metric}Percent"] = $Percent
                                        }
                                }
                            $Row['Age'] = Resolve-KubeResourceAge -Timestamp ([string]$PodItem.Metadata.CreationTimestamp)
                            [pscustomobject]$Row
                        }

                        $AllocatedResources = foreach ($Resource in ($ResourceTotals.Requests.Keys + $ResourceTotals.Limits.Keys | Sort-Object -Unique)) {
                            $Row = [ordered]@{ Resource = $Resource }
                            ForEach($Metric in 'Requests', 'Limits')
                                {
                                    $Value                   = [decimal]$ResourceTotals[$Metric][$Resource]
                                    $NodeCapacity            = ConvertTo-KubePSResourceNumber ([string]$NodeItem.Status.Allocatable[$Resource])
                                    $Percent                 = If($NodeCapacity -gt 0) { [math]::Round(($Value / $NodeCapacity) * 100) } Else { $null }
                                    $Suffix                  = If($Resource -eq 'cpu') { 'm' } ElseIf($Resource -eq 'memory' -or $Resource -eq 'ephemeral-storage' -or $Resource -like 'hugepages-*') { 'B' } Else { '' }
                                    $DisplayValue            = If($Suffix -eq 'm') { "$([math]::Round($Value * 1000))m" } ElseIf($Suffix -eq 'B') { "$([math]::Round($Value / 1MB, 2))Mi" } Else { [string]$Value }
                                    $Row[$Metric]            = $DisplayValue
                                    $Row["${Metric}Percent"] = $Percent
                                }
                            [pscustomobject]$Row
                        }

                        $Labels      = [ordered]@{}
                        $Annotations = [ordered]@{}
                        If($NodeItem.Metadata.Labels)
                            {
                                ForEach($Key in $NodeItem.Metadata.Labels.Keys)
                                    {
                                        $Labels[$Key] = $NodeItem.Metadata.Labels[$Key]
                                    }
                            }
                        If($NodeItem.Metadata.Annotations)
                            {
                                ForEach($Key in $NodeItem.Metadata.Annotations.Keys)
                                    {
                                        $Annotations[$Key] = $NodeItem.Metadata.Annotations[$Key]
                                    }
                            }

                        $Addresses = [ordered]@{}
                        ForEach($Address in $NodeItem.Status.Addresses)
                            {
                                $Addresses[$Address.Type] = $Address.Address
                            }

                        $Conditions = @($NodeItem.Status.Conditions | ForEach-Object {
                            [pscustomobject]@{
                                Type               = $_.Type
                                Status             = $_.Status
                                LastHeartbeatTime  = $_.LastHeartbeatTime
                                LastTransitionTime = $_.LastTransitionTime
                                Reason             = $_.Reason
                                Message            = $_.Message
                            }
                        })

                        $SystemInfo = [ordered]@{
                            MachineID               = $NodeItem.Status.NodeInfo.MachineID
                            SystemUUID              = $NodeItem.Status.NodeInfo.SystemUUID
                            BootID                  = $NodeItem.Status.NodeInfo.BootID
                            KernelVersion           = $NodeItem.Status.NodeInfo.KernelVersion
                            OSImage                 = $NodeItem.Status.NodeInfo.OsImage
                            ContainerRuntimeVersion = $NodeItem.Status.NodeInfo.ContainerRuntimeVersion
                            KubeletVersion          = $NodeItem.Status.NodeInfo.KubeletVersion
                            KubeProxyVersion        = $NodeItem.Status.NodeInfo.KubeProxyVersion
                            OperatingSystem         = $NodeItem.Status.NodeInfo.OperatingSystem
                            Architecture            = $NodeItem.Status.NodeInfo.Architecture
                        }
                        $Lease = [ordered]@{}
                        Try
                            {
                                $LeaseItem = [k8s.CoordinationV1OperationsExtensions]::ReadNamespacedLeaseAsync(
                                    $Script:KubePSDirectClient.CoordinationV1,
                                    $NodeName,
                                    'kube-node-lease'
                                ).GetAwaiter().GetResult()

                                $Lease = [ordered]@{
                                    HolderIdentity       = $LeaseItem.Spec.HolderIdentity
                                    LeaseDurationSeconds = $LeaseItem.Spec.LeaseDurationSeconds
                                    AcquireTime          = $LeaseItem.Spec.AcquireTime
                                    RenewTime            = $LeaseItem.Spec.RenewTime
                                    LeaseTransitions     = $LeaseItem.Spec.LeaseTransitions
                                }
                            }
                        Catch [k8s.Autorest.HttpOperationException]
                            {
                                If($_.Exception.Response.StatusCode -ne [System.Net.HttpStatusCode]::NotFound) { Throw }
                            }
                        $Events = [k8s.CoreV1OperationsExtensions]::ListEventForAllNamespacesAsync(
                            $Script:KubePSDirectClient.CoreV1,
                            $null,
                            $null,
                            "involvedObject.name=$NodeName,involvedObject.kind=Node"
                        ).GetAwaiter().GetResult().Items |
                            Where-Object { $_.InvolvedObject.Name -eq $NodeName -and $_.InvolvedObject.Kind -eq 'Node' } |
                            ForEach-Object {
                                $EventTime = If($_.LastTimestamp) { $_.LastTimestamp } ElseIf($_.EventTime) { $_.EventTime } Else { $_.Metadata.CreationTimestamp }
                                [pscustomobject]@{
                                    Type    = $_.Type
                                    Reason  = $_.Reason
                                    Age     = Resolve-KubeResourceAge -Timestamp ([string]$EventTime)
                                    From    = $_.Source.Component
                                    Message = $_.Message
                                }
                            }

                        [pscustomobject]@{
                            PSTypeName         = 'KubePS.NodeDescription'
                            Name               = $NodeItem.Metadata.Name
                            Roles              = (@($Labels.Keys | Where-Object { $_ -like 'node-role.kubernetes.io/*' } | ForEach-Object { $_.Substring('node-role.kubernetes.io/'.Length) }) -join ',')
                            Labels             = $Labels
                            Annotations        = $Annotations
                            CreationTimestamp  = $NodeItem.Metadata.CreationTimestamp
                            Taints             = @($NodeItem.Spec.Taints | ForEach-Object { "$($_.Key)=$($_.Value):$($_.Effect)" }) -join ','
                            Unschedulable      = [bool]$NodeItem.Spec.Unschedulable
                            Addresses          = $Addresses
                            Lease              = $Lease
                            Conditions         = $Conditions
                            Capacity           = $Capacity
                            Allocatable        = $Allocatable
                            SystemInfo         = $SystemInfo
                            NonTerminatedPods  = @($NonTerminatedPods)
                            AllocatedResources = @($AllocatedResources)
                            Events             = @($Events)
                            Sections           = [ordered]@{}
                        }
                    }
            }
    }