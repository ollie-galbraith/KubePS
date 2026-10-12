Function Resolve-KubeResourceAge
    {
        <#
        .SYNOPSIS
            Converts an ISO 8601 Kubernetes timestamp into a compact human-readable age string such as "3d 2h" or "15m".
            This helper is used repeatedly across KubePS to display age information for resources, pods, nodes, and events without forcing callers to manually calculate elapsed time in PowerShell.

        .EXAMPLE
            Resolve-KubeResourceAge -Timestamp '2024-06-01T12:00:00Z'
            # Returns a human-readable age such as 10d 2h.

        .EXAMPLE
            Get-KubeNodes | Select-Object Name, @{Name='Age';Expression={Resolve-KubeResourceAge -Timestamp $_.CreationTimestamp}}
            # Calculates the age for each node object from its Kubernetes timestamp.

        .EXAMPLE
            Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty Events
            # Uses Resolve-KubeResourceAge internally when building event age fields.
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True, Position=0, HelpMessage='The timestamp of the Kubernetes resource in ISO 8601 format')]
            [String]$Timestamp
        )

        $Elapsed = [System.DateTimeOffset]::UtcNow - [System.DateTimeOffset]$Timestamp
        $TotalSeconds = [math]::Floor($Elapsed.TotalSeconds)
        $RemainingSeconds = [math]::Max(0, $TotalSeconds)
        $Age = @()
        $Units = @(
            @{
                Seconds = 86400
                Suffix = 'd'
            },
            @{
                Seconds = 3600
                Suffix = 'h'
            },
            @{
                Seconds = 60
                Suffix = 'm'
            }
        )

        ForEach($Unit in $Units)
            {
                If($RemainingSeconds -ge $Unit.Seconds)
                    {
                        $MainAge = [math]::Floor($RemainingSeconds / $Unit.Seconds)
                        $Age += "$($MainAge)$($Unit.Suffix)"
                        $RemainingSeconds %= $Unit.Seconds
                        If($Age.Count -eq 2)
                            {
                                Return $Age -join ' '
                            }
                    }
            }

        If($RemainingSeconds -gt 0 -or $Age.Count -eq 0)
            {
                $Age += "$($RemainingSeconds)s"
            }

        Return $Age -join ' '
    }