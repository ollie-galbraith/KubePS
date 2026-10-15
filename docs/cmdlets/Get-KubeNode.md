## Get-KubeNode

### Description

Lists Kubernetes nodes and optionally filters them by name or output mode so operators can inspect cluster health, roles, node versions, and IP addresses at a glance.
This command queries the node inventory and returns a compact summary object by default, or a more detailed format when -OutputFormat is set to 'Detailed'.

---

```
Get-KubeNode

	[-FullOutput   <System.Management.Automation.SwitchParameter[ ]>]
	[-Node                                        <System.String[ ]>]
	[-OutputFormat                                <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeNode.ps1](../Public/Get-KubeNode.ps1)

### Examples

#### Example 1
```powershell
Get-KubeNode
# Lists every cluster node with status, role, age, and version information.
```
#### Example 2
```powershell
Get-KubeNode -Node 'worker-.*'
# Returns only nodes whose names match the regex pattern.
```
#### Example 3
```powershell
Get-KubeNode -OutputFormat Detailed
# Returns the detailed node object format with OS, runtime, kernel, and address details.
```

---

### Parameters

#### -FullOutput
|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


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
