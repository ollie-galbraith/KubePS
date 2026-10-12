Function ConvertFrom-DescriptionFields
    {
        <#
        .SYNOPSIS
            Parses indented Kubernetes description output into an ordered dictionary where each field name becomes a key and its value is preserved as a string.
            This helper is intended for output that is formatted in "Key: Value" pairs, such as resource and node detail text, so it can be transformed into structured PowerShell data for later filtering or display.

        .EXAMPLE
            $Lines = @(
                '    Name: my-pod',
                '    Namespace: default',
                '    Ready: 1/1'
            )
            ConvertFrom-DescriptionFields -Lines $Lines
            # Returns an ordered hashtable like @{ Name = 'my-pod'; Namespace = 'default'; Ready = '1/1' }

        .EXAMPLE
            $Text = @(
                '    CPU Requests: 250m',
                '    Memory Requests: 128Mi'
            )
            ConvertFrom-DescriptionFields -Lines $Text
            # Converts resource summary lines into name/value pairs for reuse in custom objects.
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True, Position=0, HelpMessage='The lines of text to convert from description fields.')]
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