## Get-KubeNodeMetric

### Description

Retrieves live CPU and memory usage for cluster nodes from the metrics API, including the percentage of each node's allocatable capacity in use.
This is the KubePS equivalent of 'kubectl top node' and requires metrics-server (metrics.k8s.io) to be installed in the cluster.

---

```
Get-KubeNodeMetric

	[-Node                                          <System.String[ ]>]
	[-Watch          <System.Management.Automation.SwitchParameter[ ]>]
	[-RefreshSeconds                                <System.Double[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeNodeMetric.ps1](../Public/Get-KubeNodeMetric.ps1)

### Examples

#### Example 1
```powershell
Get-KubeNodeMetric
# Lists CPU and memory usage for every node.
```
#### Example 2
```powershell
Get-KubeNodeMetric -Node 'worker-.*' | Sort-Object CpuPercent -Descending
# Shows usage for nodes matching worker-, busiest CPU first.
```
#### Example 3
```powershell
Get-KubeNodeMetric -Watch -RefreshSeconds 2
# Shows a live view of node usage in the alternate screen buffer, refreshing every two seconds until Ctrl+C is pressed.
```

---

### Parameters

#### -Node

The node name or regular expression to match.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -RefreshSeconds

The number of seconds between refreshes when -Watch is used.

|               |               |
| ------------- | ------------- |
| Type          | System.Double |
| Mandatory     | False         |
| DefaultValue  | 0.5           |
| ValidateRange | 0.1, 3600     |


#### -Watch

Watch the metrics

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |
