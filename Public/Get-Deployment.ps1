Function Get-Deployment
    {
        [CmdletBinding()]
        param(
            [Parameter(Position = 0, HelpMessage = 'The deployment name or regular expression to match.')]
            [string]$Deployment,
            [Parameter(HelpMessage = 'Return the full Kubernetes deployment objects.')]
            [switch]$FullOutput
        )

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Namespaces = Get-Namespace

                $ParamList = @(
                    @{
                        ParameterName    = 'Namespace'
                        ParameterType    = ([string])
                        Default          = $Script:SelectedNamespace
                        Mandatory        = $False
                        ValidateSet      = [array]$Namespaces.Name
                        HelpMessage      = 'The namespace to set as the context for retrieving deployments.'
                        Position         = 1
                        ParameterSetName = 'Namespace'
                    }
                )

                ForEach($Param in $ParamList)
                    {
                        Add-DynamicParameter @NewDynamicParams @Param
                    }
                Return $DynamicParameterDictionary
            }

        Begin
            {
                [System.Collections.Generic.List[object]]$Output = @()
                $Namespace = $DynamicParameterDictionary['Namespace'].Value
                If([string]::IsNullOrWhiteSpace($Namespace))
                    {
                        Write-Error 'Specify -Namespace or use Set-SelectedNamespace.' -Category InvalidArgument
                        Return
                    }
                $DeploymentRegexed = -not [string]::IsNullOrEmpty($Deployment) -and [System.Text.RegularExpressions.Regex]::Escape($Deployment) -ne $Deployment
            }

        Process
            {
                $Deployments = [k8s.AppsV1OperationsExtensions]::ListNamespacedDeploymentAsync($Script:KubePSDirectClient.AppsV1, $Namespace).GetAwaiter().GetResult().Items
                ForEach($DeploymentItem in $Deployments)
                    {
                        If(([string]::IsNullOrEmpty($Deployment) -eq $false) -and ($DeploymentRegexed -eq $False) -and ($DeploymentItem.Metadata.Name -ne $Deployment))
                            {
                                Continue
                            }
                        If($FullOutput)
                            {
                                $Output.Add($DeploymentItem)
                                Continue
                            }

                        $Replicas  = [int]$DeploymentItem.Spec.Replicas
                        $Ready     = If($DeploymentItem.Status.ReadyReplicas) { [int]$DeploymentItem.Status.ReadyReplicas } Else { 0 }
                        $Updated   = If($DeploymentItem.Status.UpdatedReplicas) { [int]$DeploymentItem.Status.UpdatedReplicas } Else { 0 }
                        $Available = If($DeploymentItem.Status.AvailableReplicas) { [int]$DeploymentItem.Status.AvailableReplicas } Else { 0 }
                        
                        $Output.Add([pscustomobject]@{
                            PSTypeName = 'KubePS.Deployment'
                            Name       = $DeploymentItem.Metadata.Name
                            Ready      = $Ready
                            Replicas   = $Replicas
                            UpToDate   = $Updated
                            Available  = $Available
                            Age        = [DateTimeOffset]::UtcNow - [DateTimeOffset]$DeploymentItem.Metadata.CreationTimestamp
                            Containers = $DeploymentItem.Spec.Template.Spec.Containers
                        })
                    }
            }

        End
            {
                If($DeploymentRegexed)
                    {
                        Return $Output | Where-Object Name -Match $Deployment
                    }
                Return $Output
            }
    }