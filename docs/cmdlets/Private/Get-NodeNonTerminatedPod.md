## Get-NodeNonTerminatedPod

### Description

Retrieves non-terminated pods for a specific node in a Kubernetes cluster.
This function retrieves non-terminated pods for a specific node in a Kubernetes cluster, including their resource requests and limits. It can output metrics for individual containers within the pods.

---

```
Get-NodeNonTerminatedPod

	[-Pods <System.Object[][ ]>]
	[-Node   <System.Object[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-NodeNonTerminatedPod.ps1](../../Private/Get-NodeNonTerminatedPod.ps1)

### Examples

#### Example 1
```powershell
# Retrieves non-terminated pods for the specified node and pods.
Get-NodeNonTerminatedPod -Node $Node -Pods $Pods
```

---

### Parameters

#### -Node
|           |               |
| --------- | ------------- |
| Type      | System.Object |
| Mandatory | True          |


#### -Pods
|           |                 |
| --------- | --------------- |
| Type      | System.Object[] |
| Mandatory | False           |
