Function Get-Nodes
    {
        [CmdletBinding()]
        param(
            [Parameter(Position = 0, HelpMessage = 'The name of the node to return. Supports Regex matching')]
            [string]$Node,
            [Parameter(Position = 1)]
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