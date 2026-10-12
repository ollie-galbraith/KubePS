Function Start-PortForward
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 1)]
            [ValidateRange(0, 65535)]
            [int]$LocalPort,
            [Parameter(Mandatory, Position = 2)]
            [ValidateRange(1, 65535)]
            [int]$RemotePort,
            [Parameter(Position = 3)]
            [string[]]$Addresses = @('127.0.0.1')
        )

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Pods = Get-Pod -AllNamespaces
                $Namespaces = Get-Namespace

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
                        Write-Error 'Specify -Namespace or use Set-SelectedNamespace.' -Category InvalidArgument
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