## ConvertTo-Seconds

### Description

Converts a Kubernetes-style duration such as "30s", "5m", or "2h" into the equivalent number of seconds to support log queries and time-based filtering.
This helper is used by Get-Log when the user requests only recent log output or a relative time window, allowing KubePS to pass the correct sinceSeconds value to the Kubernetes API.

---

```
ConvertTo-Seconds

	[-Duration <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[ConvertTo-Seconds.ps1](../../Private/ConvertTo-Seconds.ps1)

### Examples

#### Example 1
```powershell
ConvertTo-Seconds -Duration '30s'
# Returns 30
```
#### Example 2
```powershell
ConvertTo-Seconds -Duration '2h'
# Returns 7200
```
#### Example 3
```powershell
Get-Log -Pod api -Namespace default -Since '1h'
# Uses ConvertTo-Seconds internally to request logs from the last hour only.
```

---

### Parameters

#### -Duration

The time duration string to convert.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
