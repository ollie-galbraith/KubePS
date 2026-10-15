## Get-KubePodMetric

### Description

Retrieves live CPU and memory usage for one or more Kubernetes pods from the metrics API, either per pod or broken down per container.
This is the KubePS equivalent of 'kubectl top pod' and requires metrics-server (metrics.k8s.io) to be installed in the cluster.

---

```
Get-KubePodMetric

	[-Pod                                           <System.String[ ]>]
	[-Containers     <System.Management.Automation.SwitchParameter[ ]>]
	[-AllNamespaces  <System.Management.Automation.SwitchParameter[ ]>]
	[-Watch          <System.Management.Automation.SwitchParameter[ ]>]
	[-RefreshSeconds                                <System.Double[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubePodMetric.ps1](../Public/Get-KubePodMetric.ps1)

### Examples

#### Example 1
```powershell
Get-KubePodMetric -Namespace default
# Lists CPU and memory usage for every pod in the default namespace.
```
#### Example 2
```powershell
Get-KubePodMetric -Namespace default -Pod api -Containers
# Shows per-container CPU and memory usage for pods matching api in the default namespace.
```
#### Example 3
```powershell
Get-KubePodMetric -AllNamespaces | Sort-Object Memory -Descending | Select-Object -First 5
# Finds the five pods using the most memory across every namespace.
```

---

### Parameters

#### -AllNamespaces

Retrieve pod metrics from every namespace.

|                   |                                              |
| ----------------- | -------------------------------------------- |
| Type              | System.Management.Automation.SwitchParameter |
| Mandatory         | False                                        |
| ParameterSetNames | AllNamespaces                                |


#### -Containers

Output one row per container instead of per pod.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -Pod

The pod name or regular expression to match.

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
