Function Start-MetricWatcher
    {
        <#
        .SYNOPSIS
            Continuously redraws the output of a metrics command in the terminal's alternate screen buffer, refreshing on a fixed interval until Ctrl+C is pressed.
            This helper is used by Get-KubePodMetric and Get-KubeNodeMetric when -Watch is specified. It always restores the main screen buffer, cursor and Ctrl+C handling on exit, including when the pipeline is stopped or an error is thrown.

        .EXAMPLE
            Start-MetricWatcher -MetricCommand 'Get-PodMetrics' -MetricParameters @{ Namespace = 'default' } -Title "Pod metrics in namespace 'default'"
            # Shows a live table of pod usage in the default namespace, refreshing twice a second.

        .EXAMPLE
            Get-KubeNodeMetric -Watch -RefreshSeconds 2
            # Internally starts the watcher and shows node usage, refreshing every two seconds.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True, Position=0, HelpMessage='The name of the command that retrieves the metrics on each refresh.')]
            [string]$MetricCommand,
            [Parameter(Mandatory=$False, Position=1, HelpMessage='The parameters to splat to the metrics command on each refresh.')]
            [hashtable]$MetricParameters = @{},
            [Parameter(Mandatory=$True, Position=2, HelpMessage='The title shown at the start of the header line.')]
            [string]$Title,
            [Parameter(Mandatory=$False, Position=3, HelpMessage='The number of seconds between refreshes.')]
            [double]$RefreshSeconds = 0.5
        )

        $Escape = [char]27
        $ListenForKeys = [Console]::IsInputRedirected -eq $False

        If($ListenForKeys)
            {
                $PreviousTreatControlCAsInput = [Console]::TreatControlCAsInput
                [Console]::TreatControlCAsInput = $True
            }

        # Switch to the alternate screen buffer and hide the cursor.
        [Console]::Write("$Escape[?1049h$Escape[?25l")
        Try
            {
                While($True)
                    {
                        Try
                            {
                                $Metrics = & $MetricCommand @MetricParameters -ErrorAction Stop
                                $Body = ($Metrics | Format-Table | Out-String -Width ([Console]::WindowWidth)).Trim("`r", "`n")
                                If([string]::IsNullOrWhiteSpace($Body))
                                    {
                                        $Body = 'No metrics found.'
                                    }
                            }
                        Catch
                            {
                                $Body = "Error: $($_.Exception.Message)"
                            }

                        $Header = "$Title | every $($RefreshSeconds)s | $([DateTime]::Now.ToString('HH:mm:ss')) | Ctrl+C to exit"
                        $Lines = @($Header, '') + @($Body -split "`r?`n")

                        # Trim to the window so the frame never scrolls, then redraw from the top-left clearing stale text.
                        $Lines = $Lines | Select-Object -First ([Math]::Max([Console]::WindowHeight - 1, 1))
                        $Frame = ($Lines | ForEach-Object { "$_$Escape[K" }) -join "`n"
                        [Console]::Write("$Escape[H$Frame$Escape[J")

                        $Deadline = [DateTime]::UtcNow.AddSeconds($RefreshSeconds)
                        While([DateTime]::UtcNow -lt $Deadline)
                            {
                                If($PSCmdlet.Stopping)
                                    {
                                        Return
                                    }

                                While($ListenForKeys -and [Console]::KeyAvailable)
                                    {
                                        $Key = [Console]::ReadKey($True)
                                        If(($Key.Key -eq [ConsoleKey]::C) -and ($Key.Modifiers -band [ConsoleModifiers]::Control))
                                            {
                                                Return
                                            }
                                    }

                                Start-Sleep -Milliseconds 50
                            }
                    }
            }
        Finally
            {
                # Show the cursor and return to the main screen buffer.
                [Console]::Write("$Escape[?25h$Escape[?1049l")
                If($ListenForKeys)
                    {
                        [Console]::TreatControlCAsInput = $PreviousTreatControlCAsInput
                    }
            }
    }
