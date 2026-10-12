## Get-KubePod

### Description

Retrieves one or more Kubernetes pods from a namespace or across all namespaces, with support for filtering by name, label, and either a compact summary or full object output.
This is the primary pod discovery command in KubePS and is used by log retrieval, port forwarding, and node diagnostics workflows that need to resolve pod identities and runtime status from the cluster.

---

```
Get-KubePod

	[-Pod                                          <System.String[ ]>]
	[-Label                                        <System.String[ ]>]
	[-FullOutput    <System.Management.Automation.SwitchParameter[ ]>]
	[-AllNamespaces <System.Management.Automation.SwitchParameter[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubePod.ps1](../Public/Get-KubePod.ps1)

### Examples

#### Example 1
```powershell
Get-KubePod -Namespace default
# Lists the pods in the default namespace with key state, readiness, and age information.
```
#### Example 2
```powershell
Get-KubePod -Namespace default -Pod api
# Returns the pod named api if it exists in the default namespace.
```
#### Example 3
```powershell
Get-KubePod -AllNamespaces -Label app=frontend
# Finds all pods matching the app=frontend label across every namespace.
```

---

### Parameters

#### -AllNamespaces

Retrieve pods from every namespace.

|                   |                                              |
| ----------------- | -------------------------------------------- |
| Type              | System.Management.Automation.SwitchParameter |
| Mandatory         | False                                        |
| ParameterSetNames | AllNamespaces                                |


#### -FullOutput

Output full pod information.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -Label

The label to filter pods by.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -Pod

The pod name or regular expression to match.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |
