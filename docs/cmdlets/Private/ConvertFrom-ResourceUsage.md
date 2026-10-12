## ConvertFrom-ResourceUsage

### Description

Splits a Kubernetes resource usage string into its numeric value and percentage so results can be displayed or consumed as structured data.
This is primarily used when a resource is reported as a string such as "500Mi (50%)" and KubePS needs to preserve both the raw quantity and the utilization percentage separately.

---

```
ConvertFrom-ResourceUsage

	[-Text <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[ConvertFrom-ResourceUsage.ps1](../../Private/ConvertFrom-ResourceUsage.ps1)

### Examples

#### Example 1
```powershell
ConvertFrom-ResourceUsage -Text '500Mi (50%)'
# Returns a PSCustomObject with Value = '500Mi' and Percent = 50
```
#### Example 2
```powershell
ConvertFrom-ResourceUsage -Text '200m (25%)'
# Converts CPU values represented as milli-CPU into a formatted value/percent pair.
```

---

### Parameters

#### -Text

The resource usage string to convert.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
