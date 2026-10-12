## Start-KubePortForward

### Description

Opens a local port-forward to a pod and relays traffic between the local port and the pod's target port while keeping the connection active for interactive debugging or service access.
This command binds local listeners, creates the Kubernetes port-forward session, and forwards data bidirectionally so a local process can connect to a service inside the cluster as though it were running on the host.

---

```
Start-KubePortForward

	[-LocalPort     <System.Int32[ ]>]
	[-RemotePort    <System.Int32[ ]>]
	[-Addresses  <System.String[][ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Start-KubePortForward.ps1](../Public/Start-KubePortForward.ps1)

### Examples

#### Example 1
```powershell
Start-KubePortForward -Pod api -Namespace default -LocalPort 8080 -RemotePort 80
# Forwards local port 8080 to port 80 on the api pod.
```
#### Example 2
```powershell
Start-KubePortForward -Pod web -Namespace prod -LocalPort 9090 -RemotePort 8080 -Addresses 127.0.0.1
# Exposes the pod service locally on a specific loopback address.
```
#### Example 3
```powershell
Set-KubeSelectedNamespace -Namespace default
Start-KubePortForward -Pod api -LocalPort 8080 -RemotePort 80
# Uses the current default namespace when no namespace is explicitly provided.
```

---

### Parameters

#### -Addresses
|              |                 |
| ------------ | --------------- |
| Type         | System.String[] |
| Mandatory    | False           |
| DefaultValue | @('127.0.0.1')  |


#### -LocalPort
|               |              |
| ------------- | ------------ |
| Type          | System.Int32 |
| Mandatory     | False        |
| ValidateRange | 0, 65535     |


#### -RemotePort
|               |              |
| ------------- | ------------ |
| Type          | System.Int32 |
| Mandatory     | False        |
| ValidateRange | 1, 65535     |
