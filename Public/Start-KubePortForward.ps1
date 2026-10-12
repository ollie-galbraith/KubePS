Function Start-KubePortForward
    {
        <#
        .SYNOPSIS
            Opens a local port-forward to a pod and relays traffic between the local port and the pod's target port while keeping the connection active for interactive debugging or service access.
            This command binds local listeners, creates the Kubernetes port-forward session, and forwards data bidirectionally so a local process can connect to a service inside the cluster as though it were running on the host.

        .EXAMPLE
            Start-KubePortForward -Pod api -Namespace default -LocalPort 8080 -RemotePort 80
            # Forwards local port 8080 to port 80 on the api pod.

        .EXAMPLE
            Start-KubePortForward -Pod web -Namespace prod -LocalPort 9090 -RemotePort 8080 -Addresses 127.0.0.1
            # Exposes the pod service locally on a specific loopback address.

        .EXAMPLE
            Set-KubeSelectedNamespace -Namespace default
            Start-KubePortForward -Pod api -LocalPort 8080 -RemotePort 80
            # Uses the current default namespace when no namespace is explicitly provided.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true, Position = 1)]
            [ValidateRange(0, 65535)]
            [int]$LocalPort,
            [Parameter(Mandatory=$true, Position = 2)]
            [ValidateRange(1, 65535)]
            [int]$RemotePort,
            [Parameter(Mandatory=$False, Position = 3)]
            [string[]]$Addresses = @('127.0.0.1')
        )

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Pods = Get-KubePod -AllNamespaces
                $Namespaces = Get-KubeNamespace

                $ParamList = @(
                    @{
                        ParameterName                   = 'Pod'
                        ParameterType                   = ([string])
                        Mandatory                       = $true
                        ValidateSet                     = [array]$Pods.Name
                        Alias                           = 'Name'
                        ValueFromPipeline               = $True
                        ValueFromPipelineByPropertyName = $True
                        HelpMessage                     = 'The pod to forward a local port to.'
                        Position                        = 0
                    },
                    @{
                        ParameterName = 'Namespace'
                        ParameterType = ([string])
                        DefaultValue  = $Script:SelectedNamespace
                        ValidateSet   = [array]$Namespaces.Name
                        HelpMessage   = 'The pod namespace.'
                        Position      = 4
                    }
                )

                ForEach($Param in $ParamList)
                    {
                        Add-DynamicParameter @NewDynamicParams @Param
                    }
                Return $DynamicParameterDictionary
            }

        Process
            {
                $PodName = $DynamicParameterDictionary['Pod'].Value
                $Namespace = $DynamicParameterDictionary['Namespace'].Value
                If([string]::IsNullOrWhiteSpace($Namespace))
                    {
                        Write-Error 'Specify -Namespace or use Set-KubeSelectedNamespace.' -Category InvalidArgument
                        Return
                    }

                $BindAddresses = If($Addresses.Count -gt 0) { $Addresses } Else { @('127.0.0.1') }
                $Listeners = [System.Collections.Generic.List[System.Net.Sockets.TcpListener]]::new()
                ForEach($BindAddress in $BindAddresses)
                    {
                        ForEach($IPAddress in [System.Net.Dns]::GetHostAddresses($BindAddress))
                            {
                                $Listener = [System.Net.Sockets.TcpListener]::new($IPAddress, $LocalPort)
                                $Listener.Start()
                                $Listeners.Add($Listener)
                                $BoundPort = ([System.Net.IPEndPoint]$Listener.LocalEndpoint).Port
                                Write-Verbose "Forwarding $BindAddress`:$BoundPort to $PodName`:$RemotePort in namespace $Namespace. Press Ctrl+C to stop."
                            }
                    }
                
                Try
                    {
                        $AcceptTasks = @($Listeners | ForEach-Object { $_.AcceptTcpClientAsync() })
                        While($true)
                            {
                                $CompletedAccept           = [System.Threading.Tasks.Task]::WhenAny([System.Threading.Tasks.Task[]]$AcceptTasks).GetAwaiter().GetResult()
                                $AcceptIndex               = [array]::IndexOf([System.Threading.Tasks.Task[]]$AcceptTasks, [System.Threading.Tasks.Task]$CompletedAccept)
                                $TcpClient                 = $CompletedAccept.Result
                                $AcceptTasks[$AcceptIndex] = $Listeners[$AcceptIndex].AcceptTcpClientAsync()
                                $PodStream                 = $null
                                $NetworkStream             = $TcpClient.GetStream()
                                Try
                                    {
                                        $PodStream = [k8s.CoreV1OperationsExtensions]::ConnectGetNamespacedPodPortforwardAsync($Script:KubePSDirectClient.CoreV1, $PodName, $Namespace, $RemotePort).GetAwaiter().GetResult()
                                        $ToPod     = $NetworkStream.CopyToAsync($PodStream)
                                        $ToLocal   = $PodStream.CopyToAsync($NetworkStream)
                                        [System.Threading.Tasks.Task]::WhenAny($ToPod, $ToLocal).GetAwaiter().GetResult() | Out-Null
                                    }
                                Finally
                                    {
                                        If($PodStream)
                                            {
                                                $PodStream.Dispose()
                                            }
                                        $NetworkStream.Dispose()
                                        $TcpClient.Dispose()
                                    }
                            }
                    }
                Finally
                    {
                        ForEach($Listener in $Listeners)
                            {
                                $Listener.Stop()
                            }
                    }
            }
    }