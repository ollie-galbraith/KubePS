Function Get-KubeDeployment
    {
        <#
        .SYNOPSIS
            Lists Kubernetes deployments in a namespace and optionally filters by deployment name or regex so operators can inspect replica readiness, age, and container information quickly.
            This command queries the apps/v1 deployment API for the selected namespace and returns a compact summary by default, or full deployment objects when -FullOutput is supplied.

        .EXAMPLE
            Get-KubeDeployment -Namespace default
            # Lists deployments in the default namespace with readiness and replica summary information.

        .EXAMPLE
            Get-KubeDeployment -Namespace default -Deployment api
            # Returns the deployment named api only.

        .EXAMPLE
            Get-KubeDeployment -Namespace kube-system -Deployment 'nginx.*' -FullOutput
            # Returns the matching deployment objects with their full Kubernetes metadata.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$False, Position=0, HelpMessage='The deployment name or regular expression to match.')]
            [string]$Deployment,
            [Parameter(Mandatory=$False, HelpMessage='Return the full Kubernetes deployment objects.')]
            [switch]$FullOutput
        )

        DynamicParam
            {
                $DynamicParameterDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

                $NewDynamicParams = @{
                    DynamicParameterDictionary = $DynamicParameterDictionary
                }

                $Namespaces = Get-KubeNamespace

                $ParamList = @(
                    @{
                        ParameterName    = 'Namespace'
                        ParameterType    = ([string])
                        DefaultValue     = $Script:SelectedNamespace
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