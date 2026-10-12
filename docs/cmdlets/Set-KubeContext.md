## Set-KubeContext

### Description

Selects a Kubernetes context for the active KubePS session and rebuilds the cached client so subsequent commands target the chosen cluster.
This command uses the merged kubeconfig data and validates the requested context name before updating the session state and refreshing the direct Kubernetes client connection.

### Source Code
[Set-KubeContext.ps1](../Public/Set-KubeContext.ps1)

### Examples

#### Example 1
```powershell
Set-KubeContext -Context default
# Switches KubePS to the default cluster context.
```
#### Example 2
```powershell
Get-KubeContext -Current
# Verifies the cluster currently selected by KubePS after switching contexts.
```
#### Example 3
```powershell
Set-KubeContext -Context 'prod-cluster'
Get-KubePod -Namespace default
# Switches to the production cluster and immediately queries its pods.
```
