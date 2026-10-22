Function Get-KubePodImage
    {
        <#
        .SYNOPSIS
        Retrieves container images from Kubernetes pods. This function queries Kubernetes pods and returns the container images used within them.

        .EXAMPLE
        # Retrieves container images from all namespaces.
        Get-KubePodImage -AllNamespaces

        .EXAMPLE
        # Retrieves container images from the specified namespace.
        Get-KubePodImage -Namespace default

        .EXAMPLE
        # Retrieves container images from all namespaces excluding system namespaces.
        Get-KubePodImage -AllNamespaces -ExcludeSystem
        #>
        
        [CmdletBinding(DefaultParameterSetName="default")]
        param(
            [Parameter(Mandatory=$False, ParameterSetName="AllNamespaces", HelpMessage="Returns images from pods in all namespaces")]
            [Switch]$AllNamespaces,
            [Parameter(Mandatory=$False, HelpMessage="Excludes system based namespaces from output")]
            [Switch]$ExcludeSystem
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
                        HelpMessage      = 'The namespace to set as the context for retrieving container images.'
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
                $Namespace = $DynamicParameterDictionary['Namespace'].Value
            }

        Process
            {
                $GetKubePodParams = @{
                    FullOutput = $True
                }

                Switch($PSCmdlet.ParameterSetName)
                    {
                        'AllNamespaces'
                            {
                                $GetKubePodParams['AllNamespaces'] = $True
                            }
                        'Namespace'
                            {
                                $GetKubePodParams['Namespace'] = $Namespace
                            }
                    }

                $Pods = Get-KubePod @GetKubePodParams

                [System.Collections.Generic.List[object]]$Output = @()
                ForEach($Pod in $Pods)
                    {
                        If(($ExcludeSystem -eq $true) -and ($Pod.Metadata.NamespaceProperty -match "^hosted.*$|^kube.*$|^default$"))
                            {
                                Continue
                            }

                        $Containers = $Pod.Spec.Containers

                        ForEach($Container in $Containers)
                            {
                                $Object = [pscustomobject]@{
                                    Pod = $Pod.Metadata.Name
                                    Namespace = $Pod.Metadata.NamespaceProperty
                                    ContainerImage = $Container.Image
                                }

                                $Output.Add($Object)
                            }
                    }
            }

        End
            {
                Return $Output
            }
    }