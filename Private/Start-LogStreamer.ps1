Function Start-LogStreamer
    {
        <#
        .SYNOPSIS
            Streams log output from a Kubernetes pod log reader in real time, writing each line as it becomes available while still allowing the caller to stop the stream cleanly.
            This helper is used by Get-Log when -Follow is specified so long-lived log sessions can be displayed continuously without buffering the entire output in memory.

        .EXAMPLE
            $LogStream = [System.IO.StreamReader]::new($Stream)
            Start-LogStreamer -LogStream $LogStream
            # Reads and prints log content line by line until the stream ends or the function is stopped.

        .EXAMPLE
            Get-Log -Pod api -Namespace default -Follow -TailLines 50
            # Internally starts a log stream and prints new output as it arrives.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True, Position=0, HelpMessage='The log stream to read from.')]
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