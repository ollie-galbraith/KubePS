## Get-KubeReplicaSet

### Description

Lists replica sets in a namespace and optionally narrows the output to a specific name or regex pattern so deployment health and rollout state can be inspected quickly.
This command provides the desired, current, and ready replica counts for each replica set, which helps operators monitor deployment behavior and identify under-replicated workloads.

---

```
Get-KubeReplicaSet

	[-All        <System.Management.Automation.SwitchParameter[ ]>]
	[-ReplicaSet                                <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeReplicaSet.ps1](../Public/Get-KubeReplicaSet.ps1)

### Examples

#### Example 1
```powershell
Get-KubeReplicaSet -Namespace default
# Lists all replica sets in the default namespace.
```
#### Example 2
```powershell
Get-KubeReplicaSet -Namespace default -ReplicaSet api
# Shows only the replica set whose name matches api.
```
#### Example 3
```powershell
Get-KubeReplicaSet -Namespace default -All
# Includes replica sets with zero desired replicas so you can see inactive or scaled-down workloads.
```

---

### Parameters

#### -All

Include replica sets with zero desired replicas.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -ReplicaSet

The replica set name or regular expression to match.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |
