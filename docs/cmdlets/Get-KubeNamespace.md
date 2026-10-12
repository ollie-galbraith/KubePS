## Get-KubeNamespace

### Description

Lists Kubernetes namespaces and optionally filters them by regex so commands can validate available namespaces and populate dynamic parameter choices.
This helper queries the core/v1 namespace API and returns a lightweight object for each namespace with its name, status, and age, making it useful for setting default namespaces and building dynamic validation sets.

---

```
Get-KubeNamespace

	[-Namespace <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeNamespace.ps1](../Public/Get-KubeNamespace.ps1)

### Examples

#### Example 1
```powershell
Get-KubeNamespace
# Lists all namespaces visible to the current cluster context.
```
#### Example 2
```powershell
Get-KubeNamespace -Namespace 'kube-.*'
# Returns only namespaces whose names match the kube-.* regex pattern.
```
#### Example 2
```powershell
Get-KubeNamespace -Namespace 'kube-.*'
# Returns only namespaces whose names match the kube-.* regex pattern.
```
#### Example 4
```powershell
Set-KubeSelectedNamespace -Namespace default
# Uses the namespace list generated here to validate and set a default namespace in the current session.
```

---

### Parameters

#### -Namespace

A regular expression used to filter namespace names.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |
