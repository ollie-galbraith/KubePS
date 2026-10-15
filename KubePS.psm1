$PrivateMembers = Get-ChildItem -Path $PSScriptRoot -Include *.ps1 -Recurse
$PublicMembers = Get-ChildItem -Path "$PSScriptRoot\Public\" | ForEach-Object {$_.Name -replace ".ps1"}

ForEach($File in $PrivateMembers)
    {
        . $File.FullName
    }

Export-ModuleMember -Function $PublicMembers

Get-KubeClient