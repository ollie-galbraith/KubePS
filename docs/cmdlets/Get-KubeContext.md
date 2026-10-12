## Get-KubeContext

### Description

Lists the Kubernetes contexts available from the active kubeconfig, or returns the current KubePS context if -Current is used.
This function reads the merged cluster configuration and provides the context names used by commands such as Set-Context, Get-Pod, and Get-Nodes so users can target the right cluster without manually editing kubeconfig files.

---

```
Get-KubeContext

	[-Current <System.Management.Automation.SwitchParameter[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeContext.ps1](../Public/Get-KubeContext.ps1)

### Examples

#### Example 1
```powershell
Get-KubeContext
# Returns every context name that exists in the active kubeconfig.
```
#### Example 2
```powershell
Get-KubeContext -Current
# Returns the currently selected context for the active KubePS session.
```
#### Example 3
```powershell
Set-KubeContext -Context 'prod-cluster'
# Updates the active context and refreshes the client used by subsequent KubePS operations.
```

---

### Parameters

#### -Current

Return the context selected for the current KubePS session.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |
