Function Get-Context
    {
        [CmdletBinding()]
        param(
            [Parameter(HelpMessage = 'Return the context selected for the current KubePS session.')]
            [switch]$Current
        )

        $Configuration = Get-KubePSKubeConfig
        If($Current)
            {
                If(-not [string]::IsNullOrWhiteSpace($Script:KubePSContext))
                    {
                        Return $Script:KubePSContext
                    }
                Return $Configuration.CurrentContext
            }

        Return @($Configuration.Contexts | ForEach-Object Name)
    }