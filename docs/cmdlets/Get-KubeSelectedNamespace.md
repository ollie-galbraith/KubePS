## Get-KubeSelectedNamespace

### Description

Returns the default namespace currently selected for the active KubePS session, if one has been set.
This is used throughout the module as the default target for commands that act on a single namespace, allowing users to avoid repeating -Namespace on every call after setting a context-specific default.

### Source Code
[Get-KubeSelectedNamespace.ps1](../Public/Get-KubeSelectedNamespace.ps1)

### Examples

#### Example 1
```powershell
Set-KubeSelectedNamespace -Namespace default
Get-KubeSelectedNamespace
# Returns default after the session namespace has been configured.
```
#### Example 2
```powershell
Get-KubeSelectedNamespace
# Prints the active default namespace, or a message if no namespace has been selected yet.
```
#### Example 3
```powershell
Get-KubePod -Namespace (Get-KubeSelectedNamespace)
# Uses the current session default namespace as the target for a pod query.
```
