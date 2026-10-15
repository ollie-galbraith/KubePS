## Resolve-KubeResourceAge

### Description

Converts an ISO 8601 Kubernetes timestamp into a compact human-readable age string such as "3d 2h" or "15m".
This helper is used repeatedly across KubePS to display age information for resources, pods, nodes, and events without forcing callers to manually calculate elapsed time in PowerShell.

---

```
Resolve-KubeResourceAge

	[-Timestamp <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Resolve-KubeResourceAge.ps1](../Public/Resolve-KubeResourceAge.ps1)

### Examples

#### Example 1
```powershell
Resolve-KubeResourceAge -Timestamp '2024-06-01T12:00:00Z'
# Returns a human-readable age such as 10d 2h.
```
#### Example 2
```powershell
Get-KubeNode | Select-Object Name, @{Name='Age';Expression={Resolve-KubeResourceAge -Timestamp ## Resolve-KubeResourceAge

### Description

Converts an ISO 8601 Kubernetes timestamp into a compact human-readable age string such as "3d 2h" or "15m".
This helper is used repeatedly across KubePS to display age information for resources, pods, nodes, and events without forcing callers to manually calculate elapsed time in PowerShell.

---

```
Resolve-KubeResourceAge

	[-Timestamp <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Resolve-KubeResourceAge.ps1](../Public/Resolve-KubeResourceAge.ps1)

### Examples

<<<examples>>>

---

### Parameters

#### -Timestamp

The timestamp of the Kubernetes resource in ISO 8601 format

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |



.CreationTimestamp}}
# Calculates the age for each node object from its Kubernetes timestamp.
```
#### Example 3
```powershell
Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty Events
# Uses Resolve-KubeResourceAge internally when building event age fields.
```

---

### Parameters

#### -Timestamp

The timestamp of the Kubernetes resource in ISO 8601 format

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
