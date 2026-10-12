Function Get-SelectedNamespace
    {
        <#
        .SYNOPSIS
            Returns the default Kubernetes namespace selected for this session.

        .EXAMPLE
            Get-SelectedNamespace
        #>

        [CmdletBinding()]
        param()

        If($null -eq $Script:SelectedNamespace)
            {
                Write-Host 'No default namespace has been set. Set it with Set-SelectedNamespace.'
                Return
            }
        Return $Script:SelectedNamespace
    }