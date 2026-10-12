## Get-KubeLog

### Description

Retrieves Kubernetes pod logs for a specific pod or a set of pods selected by label, optionally filtering by container, namespace, previous container instance, time window, or tail length.
This command is the log retrieval entry point for KubePS and supports both one-off log reads and live follow mode, making it suitable for troubleshooting running applications and checking recent failures in a namespace or pod set.

---

```
Get-KubeLog

	[-Previous   <System.Management.Automation.SwitchParameter[ ]>]
	[-Since                                     <System.String[ ]>]
	[-TailLines                                  <System.Int32[ ]>]
	[-Timestamps <System.Management.Automation.SwitchParameter[ ]>]
	[-Follow     <System.Management.Automation.SwitchParameter[ ]>]
	[-Label                                     <System.String[ ]>]
	[-Container                                 <System.String[ ]>]
	[<CommonParameters>]


Get-KubeLog

	[-Previous   <System.Management.Automation.SwitchParameter[ ]>]
	[-Since                                     <System.String[ ]>]
	[-TailLines                                  <System.Int32[ ]>]
	[-Timestamps <System.Management.Automation.SwitchParameter[ ]>]
	[-Follow     <System.Management.Automation.SwitchParameter[ ]>]
	[-Pod                                       <System.String[ ]>]
	[-Container                                 <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeLog.ps1](../Public/Get-KubeLog.ps1)

### Examples

#### Example 1
```powershell
Get-KubeLog -Pod api -Namespace default
# Reads logs from the api pod in the default namespace and writes the full log output.
```
#### Example 2
```powershell
Get-KubeLog -Label app=frontend -Namespace default -TailLines 100
# Returns the last 100 log lines from pods that match the app=frontend label selector.
```
#### Example 3
```powershell
Get-KubeLog -Pod api -Namespace default -Follow -Since '30m'
# Streams new log output continuously from the past 30 minutes until the stream is stopped.
```

---

### Parameters

#### -Container

The container to retrieve logs for.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -Follow

Follow the log output.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -Label

The label to filter pods by.

|                   |               |
| ----------------- | ------------- |
| Type              | System.String |
| Mandatory         | False         |
| ParameterSetNames | Label         |


#### -Pod

The pod to retrieve logs for.

|                   |               |
| ----------------- | ------------- |
| Type              | System.String |
| Mandatory         | False         |
| ParameterSetNames | Pod           |


#### -Previous

Retrieve logs from the previous instance of the container.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -Since

The time duration to retrieve logs for. Example: 1h, 30m, 15s.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -TailLines

The number of lines to retrieve from the end of the log.

|              |              |
| ------------ | ------------ |
| Type         | System.Int32 |
| Mandatory    | False        |
| DefaultValue | $null        |


#### -Timestamps

Output the logs with timestamps.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |
