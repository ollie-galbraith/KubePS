## Start-MetricWatcher

### Description

Continuously redraws the output of a metrics command in the terminal's alternate screen buffer, refreshing on a fixed interval until Ctrl+C is pressed.
This helper is used by Get-KubePodMetric and Get-KubeNodeMetric when -Watch is specified. It always restores the main screen buffer, cursor and Ctrl+C handling on exit, including when the pipeline is stopped or an error is thrown.

---

```
Start-MetricWatcher

	[-MetricCommand                   <System.String[ ]>]
	[-MetricParameters <System.Collections.Hashtable[ ]>]
	[-Title                           <System.String[ ]>]
	[-RefreshSeconds                  <System.Double[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Start-MetricWatcher.ps1](../../Private/Start-MetricWatcher.ps1)

### Examples

#### Example 1
```powershell
Start-MetricWatcher -MetricCommand 'Get-PodMetrics' -MetricParameters @{ Namespace = 'default' } -Title "Pod metrics in namespace 'default'"
# Shows a live table of pod usage in the default namespace, refreshing twice a second.
```
#### Example 2
```powershell
Get-KubeNodeMetric -Watch -RefreshSeconds 2
# Internally starts the watcher and shows node usage, refreshing every two seconds.
```

---

### Parameters

#### -MetricCommand

The name of the command that retrieves the metrics on each refresh.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |


#### -MetricParameters

The parameters to splat to the metrics command on each refresh.

|              |                              |
| ------------ | ---------------------------- |
| Type         | System.Collections.Hashtable |
| Mandatory    | False                        |
| DefaultValue | @{}                          |


#### -RefreshSeconds

The number of seconds between refreshes.

|              |               |
| ------------ | ------------- |
| Type         | System.Double |
| Mandatory    | False         |
| DefaultValue | 0.5           |


#### -Title

The title shown at the start of the header line.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
