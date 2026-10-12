Function Start-LogStreamer
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'The log stream to read from.')]
            [System.IO.StreamReader]$LogStream
        )

        $ReadCancellation = [System.Threading.CancellationTokenSource]::new()
        Try
            {
                While($True)
                    {
                        $ReadTask = $LogStream.ReadLineAsync($ReadCancellation.Token).AsTask()
                        While($ReadTask.IsCompleted -eq $False)
                            {
                                Try
                                    {
                                        $null = $ReadTask.Wait(100)
                                    }
                                Catch [System.AggregateException]
                                    {
                                        Break
                                    }

                                If($PSCmdlet.Stopping)
                                    {
                                        $ReadCancellation.Cancel()
                                        Return
                                    }
                            }

                        $Line = $ReadTask.GetAwaiter().GetResult()
                        If($null -eq $Line)
                            {
                                Break
                            }
                        Write-Output $Line
                    }
            }
        Catch [System.OperationCanceledException]
            {
                If($PSCmdlet.Stopping -eq $False)
                    {
                        Throw
                    }
            }
        Finally
            {
                $ReadCancellation.Dispose()
            }
    }