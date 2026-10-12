## Set-KubeSelectedNamespace

### Description

Sets the default namespace used by KubePS for commands that accept a namespace implicitly, making the current session operate within a single target namespace by default.
This command updates the module-scoped selected namespace value and is used by commands such as Get-Pod, Get-Deployment, and Get-Log when no explicit namespace is supplied.

### Source Code
[Set-KubeSelectedNamespace.ps1](../Public/Set-KubeSelectedNamespace.ps1)

### Examples

#### Example 1
```powershell
Set-KubeSelectedNamespace -Namespace default
# Uses the default namespace for later calls that do not specify -Namespace.
```
#### Example 2
```powershell
Set-KubeSelectedNamespace -Namespace kube-system
Get-KubePod
# Lists pods from kube-system without repeating -Namespace kube-system each time.
```
#### Example 3
```powershell
Get-KubeSelectedNamespace
# Confirms which namespace is currently selected for the session.
```
