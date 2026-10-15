## Get-KubeNodePodResource

### Description

Lists the non-terminated pods running on one or more nodes so operators can quickly correlate a node with the workloads scheduled on it.
This helper wraps the detailed node description objects and returns only the pod inventory for the selected node names, which is useful for troubleshooting scheduling, evictions, and workload placement.

---

```
Get-KubeNodePodResource

	[-Pod <System.String[][ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeNodePodResource.ps1](../Public/Get-KubeNodePodResource.ps1)

### Examples

#### Example 1
```powershell
Get-KubeNodePods -Node worker-1
# Lists every non-terminated pod currently assigned to worker-1.
```
#### Example 2
```powershell
Get-KubeNodePods -Node worker-1,worker-2 | Select-Object Name, Namespace, Status
# Shows a concise list of pods across multiple nodes with key fields.
```
#### Example 3
```powershell
Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty NonTerminatedPods
# Retrieves the same workload detail from the full node description object.
```

---

### Parameters

#### -Pod
|           |                 |
| --------- | --------------- |
| Type      | System.String[] |
| Mandatory | False           |
