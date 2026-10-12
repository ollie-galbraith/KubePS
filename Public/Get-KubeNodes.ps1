Function Get-KubeNodes
    {
        <#
        .SYNOPSIS
            Lists Kubernetes nodes and optionally filters them by name or output mode so operators can inspect cluster health, roles, node versions, and IP addresses at a glance.
            This command queries the node inventory and returns a compact summary object by default, or a more detailed format when -OutputFormat is set to 'Detailed'.

        .EXAMPLE
            Get-KubeNodes
            # Lists every cluster node with status, role, age, and version information.

        .EXAMPLE
            Get-KubeNodes -Node 'worker-.*'
            # Returns only nodes whose names match the regex pattern.

        .EXAMPLE
            Get-KubeNodes -OutputFormat Detailed
            # Returns the detailed node object format with OS, runtime, kernel, and address details.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$false, Position = 0, HelpMessage = 'The name of the node to return. Supports Regex matching')]
            [string]$Node,
            [Parameter(Mandatory=$false, Position = 1)]
            [ValidateSet('Wide', 'Detailed')]
            [Alias('Output')]
            [string]$OutputFormat
        )

        [System.Collections.Generic.List[object]]$Results = @()

        $NodeRegexed = -not [string]::IsNullOrEmpty($Node) -and [System.Text.RegularExpressions.Regex]::Escape($Node) -ne $Node
        $NodeItems = [k8s.CoreV1OperationsExtensions]::ListNodeAsync($Script:KubePSDirectClient.CoreV1).GetAwaiter().GetResult().Items
        ForEach($NodeItem in $NodeItems)
            {
                If(([string]::IsNullOrEmpty($Node) -eq $False) -and ($NodeRegexed -eq $False) -and ($NodeItem.Metadata.Name -ne $Node))
                    {
                        Continue
                    }

                $ReadyCondition = $NodeItem.Status.Conditions | Where-Object Type -EQ 'Ready' | Select-Object -First 1
                $Status = If($ReadyCondition -and $ReadyCondition.Status -eq 'True') { 'Ready' } ElseIf($ReadyCondition) { 'NotReady' } Else { 'Unknown' }
                If($NodeItem.Spec.Unschedulable)
                    {
                        $Status += ',SchedulingDisabled'
                    }

                $Roles = @($NodeItem.Metadata.Labels.Keys |
                    Where-Object { $_ -like 'node-role.kubernetes.io/*' } |
                    ForEach-Object { $_.Substring('node-role.kubernetes.io/'.Length) })

                If($Roles.Count -eq 0)
                    {
                        $Roles = @('<none>')
                    }

                $InternalAddress = $NodeItem.Status.Addresses | Where-Object Type -EQ 'InternalIP' | Select-Object -First 1
                $ExternalAddress = $NodeItem.Status.Addresses | Where-Object Type -EQ 'ExternalIP' | Select-Object -First 1

                $Object = [pscustomobject]@{
                    PSTypeName       = 'KubePS.Node'
                    Name             = $NodeItem.Metadata.Name
                    Status           = $Status
                    Roles            = $Roles -join ','
                    Age              = [DateTimeOffset]::UtcNow - [DateTimeOffset]$NodeItem.Metadata.CreationTimestamp
                    Version          = [Version]($NodeItem.Status.NodeInfo.KubeletVersion -replace '^v', '')
                    InternalIP       = If($InternalAddress) { [IPAddress]$InternalAddress.Address } Else { $null }
                    ExternalIP       = If($ExternalAddress) { [IPAddress]$ExternalAddress.Address } Else { $null }
                    Kernel           = $NodeItem.Status.NodeInfo.KernelVersion
                    OSImage          = $NodeItem.Status.NodeInfo.OsImage
                    ContainerRuntime = $NodeItem.Status.NodeInfo.ContainerRuntimeVersion
                }
                If($OutputFormat)
                    {
                        $Object.PSObject.TypeNames.Insert(0, "KubePS.Node.$OutputFormat")
                    }

                $Results.Add($Object)
            }

        If($NodeRegexed)
            {
                Return $Results | Where-Object Name -Match $Node
            }
        Return $Results
    }