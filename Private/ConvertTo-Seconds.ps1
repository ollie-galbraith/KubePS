Function ConvertTo-Seconds
    {
        <#
        .SYNOPSIS
            Converts a Kubernetes-style duration such as "30s", "5m", or "2h" into the equivalent number of seconds to support log queries and time-based filtering.
            This helper is used by Get-Log when the user requests only recent log output or a relative time window, allowing KubePS to pass the correct sinceSeconds value to the Kubernetes API.

        .EXAMPLE
            ConvertTo-Seconds -Duration '30s'
            # Returns 30

        .EXAMPLE
            ConvertTo-Seconds -Duration '2h'
            # Returns 7200

        .EXAMPLE
            Get-Log -Pod api -Namespace default -Since '1h'
            # Uses ConvertTo-Seconds internally to request logs from the last hour only.
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True, Position=0, HelpMessage='The time duration string to convert.')]
            [ValidatePattern('^\d+[smhd]$')]
            [string]$Duration
        )

        $Value = [int](($Duration -replace ' ', '') -replace '[smhd]', '')
        $Unit = $Duration[-1]

        Switch($Unit)
            {
                's' { Return $Value }
                'm' { Return $Value * 60 }
                'h' { Return $Value * 3600 }
                'd' { Return $Value * 86400 }
                Default { Throw "Invalid time unit: $Unit" }
            }
    }