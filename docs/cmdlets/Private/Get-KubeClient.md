## Get-KubeClient

### Description

Builds and caches the Kubernetes .NET client used by the module, reusing it when the kubeconfig or selected context has not changed.
This helper resolves the correct config source, rebuilds the client when needed, and ensures later commands call the same authenticated cluster client without repeatedly creating a new connection.

### Source Code
[Get-KubeClient.ps1](../../Private/Get-KubeClient.ps1)

### Examples

#### Example 1
```powershell
Get-KubeClient
# Creates the Kubernetes client using the selected context and current kubeconfig.
```
#### Example 2
```powershell
Set-KubeContext -Context 'production'
Get-KubeClient
# Rebuilds the client after switching to a different cluster context.
```
#### Example 3
```powershell
$Client = Get-KubeClient
$Client.CoreV1.ListNamespaceAsync($null)
# Gets the cached Kubernetes client object for lower-level API calls.
```
