## ConvertFrom-DescriptionFields

### Description

Parses indented Kubernetes description output into an ordered dictionary where each field name becomes a key and its value is preserved as a string.
This helper is intended for output that is formatted in "Key: Value" pairs, such as resource and node detail text, so it can be transformed into structured PowerShell data for later filtering or display.

---

```
ConvertFrom-DescriptionFields

	[-Lines <System.String[][ ]>]
	[<CommonParameters>]

```

---

### Source Code
[ConvertFrom-DescriptionFields.ps1](../../Private/ConvertFrom-DescriptionFields.ps1)

### Examples

#### Example 1
```powershell
$Lines = @(
    '    Name: my-pod',
    '    Namespace: default',
    '    Ready: 1/1'
)
ConvertFrom-DescriptionFields -Lines $Lines
# Returns an ordered hashtable like @{ Name = 'my-pod'; Namespace = 'default'; Ready = '1/1' }
```
#### Example 2
```powershell
$Text = @(
    '    CPU Requests: 250m',
    '    Memory Requests: 128Mi'
)
ConvertFrom-DescriptionFields -Lines $Text
# Converts resource summary lines into name/value pairs for reuse in custom objects.
```

---

### Parameters

#### -Lines

The lines of text to convert from description fields.

|           |                 |
| --------- | --------------- |
| Type      | System.String[] |
| Mandatory | True            |
