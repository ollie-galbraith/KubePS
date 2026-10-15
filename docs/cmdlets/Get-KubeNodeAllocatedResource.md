## Get-KubeNodeAllocatedResource

### Description

Summarizes the CPU, memory, and other resource requests and limits currently allocated across selected cluster nodes.
This command inspects node allocatable data alongside pod resource usage and returns a per-node breakdown showing requested and limited capacity by metric, including percentages relative to the node’s available resources.

### Source Code
[Get-KubeNodeAllocatedResource.ps1](../Public/Get-KubeNodeAllocatedResource.ps1)

### Examples

#### Example 1
```powershell
Get-KubeNodeAllocatedResources -Node worker-1
# Returns the request and limit usage summary for the worker-1 node.
```
#### Example 2
```powershell
Get-KubeNodeAllocatedResources -Node worker-1,worker-2
# Produces a resource allocation summary for multiple nodes in a single call.
```
#### Example 3
```powershell
Get-KubeNodeDescription -Node worker-1 | Select-Object -ExpandProperty AllocatedResources
# Shows the same underlying allocation data in the detailed node description object.
```
