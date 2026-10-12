Function ConvertTo-Seconds
    {
        <#
        .SYNOPSIS
            Converts a time duration string into seconds.
            This function takes a time duration string in the format "1h", "30m", or "15s" and converts it into the equivalent number of seconds.

        .EXAMPLE
            ConvertTo-Seconds -Duration '1h'
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'The time duration string to convert.')]
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