# Test if kubectl is available 
$PrivateMembers = Get-ChildItem -Path $PSScriptRoot -Include *.ps1 -Recurse
$PublicMembers = Get-ChildItem -Path "$PSScriptRoot\Public\" | ForEach-Object {$_.Name -replace ".ps1"}

ForEach($File in $PrivateMembers)
    {
        . $File.FullName
    }

Update-FormatData -PrependPath (Join-Path $PSScriptRoot 'KubePS.format.ps1xml') -ErrorAction Stop

Export-ModuleMember -Function $PublicMembers

Get-KubePSClient