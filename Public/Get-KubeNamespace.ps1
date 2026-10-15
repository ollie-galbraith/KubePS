function Get-KubeNamespace
    {
        <#
        .SYNOPSIS
            Lists Kubernetes namespaces and optionally filters them by regex so commands can validate available namespaces and populate dynamic parameter choices.
            This helper queries the core/v1 namespace API and returns a lightweight object for each namespace with its name, status, and age, making it useful for setting default namespaces and building dynamic validation sets.

        .EXAMPLE
            Get-KubeNamespace
            # Lists all namespaces visible to the current cluster context.

        .EXAMPLE
            Get-KubeNamespace -Namespace 'kube-.*'
            # Returns only namespaces whose names match the kube-.* regex pattern.

        .EXAMPLE
            Get-KubeNamespace -Namespace 'kube-.*'
            # Returns only namespaces whose names match the kube-.* regex pattern.

        .EXAMPLE
            Set-KubeSelectedNamespace -Namespace default
            # Uses the namespace list generated here to validate and set a default namespace in the current session.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$false, Position = 0, HelpMessage = 'A regular expression used to filter namespace names.')]
            [string]$Namespace
        )

        $Namespaces = [k8s.CoreV1OperationsExtensions]::ListNamespaceAsync($Script:KubePSDirectClient.CoreV1).GetAwaiter().GetResult().Items

        foreach ($Item in $Namespaces) {
            If(-not [string]::IsNullOrEmpty($Namespace) -and $Item.Metadata.Name -notmatch $Namespace)
                {
                    Continue
                }

            [PSCustomObject]@{
                PSTypeName = 'KubePS.Namespace'
                Name       = $Item.Metadata.Name
                Status     = $Item.Status.Phase
                Age        = [DateTimeOffset]::UtcNow - [DateTimeOffset]$Item.Metadata.CreationTimestamp
            }
        }
    }