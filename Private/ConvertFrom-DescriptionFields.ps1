Function ConvertFrom-DescriptionFields
    {
        <#
        .SYNOPSIS
            Converts lines of text from description fields into a hashtable.
            This function takes an array of lines containing description fields in the format "    Key: Value"
            and converts them into an ordered hashtable where the keys are the field names and the values are the field values.

        .EXAMPLE
            $lines = @(
                '    Name: MyPod',
                '    Namespace: default'
            )
            ConvertFrom-DescriptionFields -Lines $lines
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'The lines of text to convert from description fields.')]
            [string[]]$Lines
        )

        $Fields = [ordered]@{}
        ForEach($Line in $Lines)
            {
                If($Line -match '^\s+([^:]+):\s*(.*)$')
                    {
                        $Fields[$Matches[1].Trim()] = $Matches[2].Trim()
                    }
            }

        Return $Fields
    }