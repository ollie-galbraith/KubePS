## Start-LogStreamer

### Description

Streams log output from a Kubernetes pod log reader in real time, writing each line as it becomes available while still allowing the caller to stop the stream cleanly.
This helper is used by Get-Log when -Follow is specified so long-lived log sessions can be displayed continuously without buffering the entire output in memory.

---

```
Start-LogStreamer

	[-LogStream <System.IO.StreamReader[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Start-LogStreamer.ps1](../../Private/Start-LogStreamer.ps1)

### Examples

#### Example 1
```powershell
$LogStream = [System.IO.StreamReader]::new($Stream)
Start-LogStreamer -LogStream $LogStream
# Reads and prints log content line by line until the stream ends or the function is stopped.
```
#### Example 2
```powershell
Get-Log -Pod api -Namespace default -Follow -TailLines 50
# Internally starts a log stream and prints new output as it arrives.
```

---

### Parameters

#### -LogStream

The log stream to read from.

|           |                        |
| --------- | ---------------------- |
| Type      | System.IO.StreamReader |
| Mandatory | True                   |
