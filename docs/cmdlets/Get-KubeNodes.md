## Get-KubeNodes

### Description

Lists Kubernetes nodes and optionally filters them by name or output mode so operators can inspect cluster health, roles, node versions, and IP addresses at a glance.
This command queries the node inventory and returns a compact summary object by default, or a more detailed format when -OutputFormat is set to 'Detailed'.

---

```
Get-KubeNodes

	[-Node         <System.String[ ]>]
	[-OutputFormat <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeNodes.ps1](../Public/Get-KubeNodes.ps1)

### Examples

#### Example 1
```powershell
Get-KubeNodes
# Lists every cluster node with status, role, age, and version information.
```
#### Example 2
```powershell
Get-KubeNodes -Node 'worker-.*'
# Returns only nodes whose names match the regex pattern.
```
#### Example 3
```powershell
Get-KubeNodes -OutputFormat Detailed
# Returns the detailed node object format with OS, runtime, kernel, and address details.
```

---

### Parameters

#### -Node

The name of the node to return. Supports Regex matching

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -OutputFormat
|             |                |
| ----------- | -------------- |
| Type        | System.String  |
| Mandatory   | False          |
| ValidateSet | Wide, Detailed |
