## Get-PodMetrics

### Description

Retrieves metrics for pods in a Kubernetes cluster.
This function retrieves metrics for pods in a Kubernetes cluster, including CPU and memory usage. It can retrieve metrics for all namespaces or a specific namespace, and can output metrics for individual containers within the pods.

---

```
Get-PodMetrics

	[-Pod                                          <System.String[ ]>]
	[-Namespace                                    <System.String[ ]>]
	[-Containers    <System.Management.Automation.SwitchParameter[ ]>]
	[-AllNamespaces <System.Management.Automation.SwitchParameter[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-PodMetrics.ps1](../../Private/Get-PodMetrics.ps1)

### Examples

#### Example 1
```powershell
# Retrieves metrics for all pods in the 'default' namespace.
Get-PodMetrics -Namespace 'default'
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


#### -Namespace

The namespace to query. Required unless -AllNamespaces is used.

|              |                           |
| ------------ | ------------------------- |
| Type         | System.String             |
| Mandatory    | False                     |
| DefaultValue | $Script:SelectedNamespace |


#### -Pod

The pod name or regular expression to match.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |
