## Get-KubeDeployment

### Description

Lists Kubernetes deployments in a namespace and optionally filters by deployment name or regex so operators can inspect replica readiness, age, and container information quickly.
This command queries the apps/v1 deployment API for the selected namespace and returns a compact summary by default, or full deployment objects when -FullOutput is supplied.

---

```
Get-KubeDeployment

	[-FullOutput <System.Management.Automation.SwitchParameter[ ]>]
	[-Deployment                                <System.String[ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Get-KubeDeployment.ps1](../Public/Get-KubeDeployment.ps1)

### Examples

#### Example 1
```powershell
Get-KubeDeployment -Namespace default
# Lists deployments in the default namespace with readiness and replica summary information.
```
#### Example 2
```powershell
Get-KubeDeployment -Namespace default -Deployment api
# Returns the deployment named api only.
```
#### Example 3
```powershell
Get-KubeDeployment -Namespace kube-system -Deployment 'nginx.*' -FullOutput
# Returns the matching deployment objects with their full Kubernetes metadata.
```

---

### Parameters

#### -Deployment

The deployment name or regular expression to match.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -FullOutput

Return the full Kubernetes deployment objects.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |
