## Get-NodeMetrics

### Description

Retrieves live CPU and memory usage for cluster nodes from the metrics API and calculates the percentage of each node's allocatable capacity in use.
This helper is used by Get-KubeNodeMetric, both for one-off output and on each refresh when -Watch is specified.

---

```
Get-NodeMetrics

	[-Node <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-NodeMetrics.ps1](../../Private/Get-NodeMetrics.ps1)

### Examples

#### Example 1
```powershell
Get-NodeMetrics
# Returns CPU and memory usage for every node.
```
#### Example 2
```powershell
Get-NodeMetrics -Node 'worker-.*'
# Returns usage only for nodes whose names match the regex pattern.
```

---

### Parameters

#### -Node

The node name or regular expression to match.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |
