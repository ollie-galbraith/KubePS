## ConvertTo-KubePSResourceNumber

### Description

Converts Kubernetes resource quantities such as milli-CPU, memory values, and SI/IEC suffixes into a decimal number that can be used for math and percentage calculations.
This helper normalizes values like "250m", "512Mi", "1Gi", or "500m" into a common base unit so KubePS can compare requests, limits, and allocatable totals across CPU and memory metrics.

---

```
ConvertTo-KubePSResourceNumber

	[-Quantity <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[ConvertTo-KubePSResourceNumber.ps1](../../Private/ConvertTo-KubePSResourceNumber.ps1)

### Examples

#### Example 1
```powershell
ConvertTo-KubePSResourceNumber -Quantity '250m'
# Returns 0.25, which is useful for CPU calculations.
```
#### Example 2
```powershell
ConvertTo-KubePSResourceNumber -Quantity '1Gi'
# Returns 1073741824, which is the byte-equivalent for a 1 GiB allocation.
```

---

### Parameters

#### -Quantity
|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |
