### KubePS

##### Description

Kubernetes PowerShell cmdlets built on the official Kubernetes .NET client.
*****

##### Available Cmdlets
+ [Get-KubeContext](docs/cmdlets/Get-KubeContext.md)
+ [Get-KubeDeployment](docs/cmdlets/Get-KubeDeployment.md)
+ [Get-KubeLog](docs/cmdlets/Get-KubeLog.md)
+ [Get-KubeNamespace](docs/cmdlets/Get-KubeNamespace.md)
+ [Get-KubeNode](docs/cmdlets/Get-KubeNode.md)
+ [Get-KubeNodeAllocatedResource](docs/cmdlets/Get-KubeNodeAllocatedResource.md)
+ [Get-KubeNodeDescription](docs/cmdlets/Get-KubeNodeDescription.md)
+ [Get-KubeNodeMetric](docs/cmdlets/Get-KubeNodeMetric.md)
+ [Get-KubeNodePodResource](docs/cmdlets/Get-KubeNodePodResource.md)
+ [Get-KubePod](docs/cmdlets/Get-KubePod.md)
+ [Get-KubePodMetric](docs/cmdlets/Get-KubePodMetric.md)
+ [Get-KubeReplicaSet](docs/cmdlets/Get-KubeReplicaSet.md)
+ [Get-KubeSelectedNamespace](docs/cmdlets/Get-KubeSelectedNamespace.md)
+ [Resolve-KubeResourceAge](docs/cmdlets/Resolve-KubeResourceAge.md)
+ [Set-KubeContext](docs/cmdlets/Set-KubeContext.md)
+ [Set-KubeSelectedNamespace](docs/cmdlets/Set-KubeSelectedNamespace.md)
+ [Start-KubePortForward](docs/cmdlets/Start-KubePortForward.md)

##### Private Functions
+ [Add-DynamicParameter](docs/cmdlets/Private/Add-DynamicParameter.md)
+ [ConvertFrom-DescriptionFields](docs/cmdlets/Private/ConvertFrom-DescriptionFields.md)
+ [ConvertFrom-ResourceUsage](docs/cmdlets/Private/ConvertFrom-ResourceUsage.md)
+ [ConvertTo-KubePSResourceNumber](docs/cmdlets/Private/ConvertTo-KubePSResourceNumber.md)
+ [ConvertTo-Seconds](docs/cmdlets/Private/ConvertTo-Seconds.md)
+ [Get-KubeClient](docs/cmdlets/Private/Get-KubeClient.md)
+ [Get-KubeConfig](docs/cmdlets/Private/Get-KubeConfig.md)
+ [Get-NodeAllocatedResource](docs/cmdlets/Private/Get-NodeAllocatedResource.md)
+ [Get-NodeMetrics](docs/cmdlets/Private/Get-NodeMetrics.md)
+ [Get-NodeNonTerminatedPod](docs/cmdlets/Private/Get-NodeNonTerminatedPod.md)
+ [Get-PodMetrics](docs/cmdlets/Private/Get-PodMetrics.md)
+ [Start-LogStreamer](docs/cmdlets/Private/Start-LogStreamer.md)
+ [Start-MetricWatcher](docs/cmdlets/Private/Start-MetricWatcher.md)

*****

##### Usage
To install and use this module, use the following code

```powershell
PS C:\> Install-Module -Name KubePS

PS C:\> Import-Module -Name KubePS
```
