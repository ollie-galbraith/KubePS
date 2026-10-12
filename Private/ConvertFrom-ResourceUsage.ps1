Function ConvertFrom-ResourceUsage
    {
        <#
        .SYNOPSIS
            Converts a resource usage string into a custom object with value and percent.
            This function takes a resource usage string in the format "Value (Percent%)" and converts it into a custom object with separate properties for the value and the percent.

        .EXAMPLE
            ConvertFrom-ResourceUsage -Text '500Mi (50%)'
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'The resource usage string to convert.')]
            [string]$Text
        )

        $Value = $Text
        $Percent = $null
        If($Text -match '^(.*?)\s+\((\d+)%\)$')
            {
                $Value = $Matches[1]
                $Percent = [int]$Matches[2]
            }

        [pscustomobject]@{
            Value   = $Value
            Percent = $Percent
        }
    }