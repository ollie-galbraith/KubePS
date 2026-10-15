## Get-NodeAllocatedResource

### Description

Retrieves allocated resources for a specific node in a Kubernetes cluster.
This function retrieves allocated resources for a specific node in a Kubernetes cluster, including CPU and memory usage. It can output metrics for individual containers within the pods.

---

```
Get-NodeAllocatedResource

	[-Pods <System.Object[][ ]>]
	[-Node   <System.Object[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-NodeAllocatedResource.ps1](../../Private/Get-NodeAllocatedResource.ps1)

### Examples

#### Example 1
```powershell
# Retrieves allocated resources for the specified node and pods.
Get-NodeAllocatedResource -Node $Node -Pods $Pods
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
| Mandatory | True            |
