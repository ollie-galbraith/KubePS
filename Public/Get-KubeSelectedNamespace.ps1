Function Get-KubeSelectedNamespace
    {
        <#
        .SYNOPSIS
            Returns the default namespace currently selected for the active KubePS session, if one has been set.
            This is used throughout the module as the default target for commands that act on a single namespace, allowing users to avoid repeating -Namespace on every call after setting a context-specific default.

        .EXAMPLE
            Set-KubeSelectedNamespace -Namespace default
            Get-KubeSelectedNamespace
            # Returns default after the session namespace has been configured.

        .EXAMPLE
            Get-KubeSelectedNamespace
            # Prints the active default namespace, or a message if no namespace has been selected yet.

        .EXAMPLE
            Get-KubePod -Namespace (Get-KubeSelectedNamespace)
            # Uses the current session default namespace as the target for a pod query.
        #>

        [CmdletBinding()]
        param()

        If($null -eq $Script:SelectedNamespace)
            {
                Write-Host 'No default namespace has been set. Set it with Set-KubeSelectedNamespace.'
                Return
            }
        Return $Script:SelectedNamespace
    }