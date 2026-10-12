Function Get-KubeContext
    {
        <#
        .SYNOPSIS
            Lists the Kubernetes contexts available from the active kubeconfig, or returns the current KubePS context if -Current is used.
            This function reads the merged cluster configuration and provides the context names used by commands such as Set-Context, Get-Pod, and Get-Nodes so users can target the right cluster without manually editing kubeconfig files.

        .EXAMPLE
            Get-KubeContext
            # Returns every context name that exists in the active kubeconfig.

        .EXAMPLE
            Get-KubeContext -Current
            # Returns the currently selected context for the active KubePS session.

        .EXAMPLE
            Set-KubeContext -Context 'prod-cluster'
            # Updates the active context and refreshes the client used by subsequent KubePS operations.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$False, HelpMessage='Return the context selected for the current KubePS session.')]
            [switch]$Current
        )

        $Configuration = Get-KubeConfig
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