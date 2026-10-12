Function Resolve-ResourceAge
    {
        <#
        .SYNOPSIS
            Resolves the age of a Kubernetes resource based on its timestamp.
            This function calculates the elapsed time since the provided timestamp and returns it in a human-readable format (days, hours, minutes, or seconds).

        .EXAMPLE
            Resolve-ResourceAge -Timestamp "2024-06-01T12:00:00Z"
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