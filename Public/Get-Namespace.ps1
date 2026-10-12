function Get-Namespace
    {
        [CmdletBinding()]
        param(
            [Parameter(Position = 0, HelpMessage = 'A regular expression used to filter namespace names.')]
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