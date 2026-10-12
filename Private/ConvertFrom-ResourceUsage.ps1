Function ConvertFrom-ResourceUsage
    {
        <#
        .SYNOPSIS
            Splits a Kubernetes resource usage string into its numeric value and percentage so results can be displayed or consumed as structured data.
            This is primarily used when a resource is reported as a string such as "500Mi (50%)" and KubePS needs to preserve both the raw quantity and the utilization percentage separately.

        .EXAMPLE
            ConvertFrom-ResourceUsage -Text '500Mi (50%)'
            # Returns a PSCustomObject with Value = '500Mi' and Percent = 50

        .EXAMPLE
            ConvertFrom-ResourceUsage -Text '200m (25%)'
            # Converts CPU values represented as milli-CPU into a formatted value/percent pair.
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True, Position=0, HelpMessage='The resource usage string to convert.')]
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