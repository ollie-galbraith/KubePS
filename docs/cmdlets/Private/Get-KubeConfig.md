## Get-KubeConfig

### Description

Loads and merges the active Kubernetes kubeconfig files into a single configuration object that KubePS uses for cluster operations.
This helper checks the KUBECONFIG environment variable or the default kubeconfig location, reads each config file, and combines contexts, clusters, and users so commands like Set-Context and Get-Context can work against the same merged view of the cluster configuration.

### Source Code
[Get-KubeConfig.ps1](../../Private/Get-KubeConfig.ps1)

### Examples

#### Example 1
```powershell
Get-KubePSKubeConfig
# Returns the merged kubeconfig currently being used by KubePS.
```
#### Example 2
```powershell
$Config = Get-KubePSKubeConfig
$Config.CurrentContext
# Displays the currently selected context after any merged kubeconfig files are read.
```
#### Example 3
```powershell
$env:KUBECONFIG = "$HOME/.kube/config:$HOME/.kube/team-config"
Get-KubePSKubeConfig
# Loads both kubeconfig files and combines their contexts and users before selecting an active context.
```
