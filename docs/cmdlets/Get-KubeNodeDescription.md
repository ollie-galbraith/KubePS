## Get-KubeNodeDescription

### Description

Returns a rich description of one or more Kubernetes nodes, including labels, taints, conditions, addresses, system info, allocated resources, and the non-terminated pods currently running on each node.
This command is the detailed node inspection tool in KubePS and is used by other node-oriented commands to gather capacity and workload information before summarizing it for users.

### Source Code
[Get-KubeNodeDescription.ps1](../Public/Get-KubeNodeDescription.ps1)

### Examples

#### Example 1
```powershell
Get-KubeNodeDescription -Node worker-1
# Returns the full metadata and scheduling information for worker-1.
```
#### Example 2
```powershell
Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty Conditions
# Lists the current readiness, memory pressure, disk pressure, and PID pressure conditions for the node.
```
#### Example 3
```powershell
Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty AllocatedResources
# Displays how much CPU and memory requests/limits are currently used by workloads on that node.
```
