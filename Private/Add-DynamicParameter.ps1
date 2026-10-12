Function Add-DynamicParameter
    {
        <#
        .SYNOPSIS
            Creates and registers a dynamic PowerShell parameter in a RuntimeDefinedParameterDictionary so advanced functions can validate input against live data such as namespace names, pod names, or node names without hardcoding those values in the static param block.
            This helper is used throughout KubePS to build dynamic parameters for context-aware commands that need to reflect the current cluster state at runtime, including validation sets, aliases, default values, mandatory flags, and custom completion metadata.

        .EXAMPLE
            $DynamicParameters = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
            Add-DynamicParameter -DynamicParameterDictionary $DynamicParameters -ParameterName 'Namespace' -ParameterType ([string]) -Mandatory -ValidateSet @('default', 'kube-system') -HelpMessage 'Namespace to query.'
            # Creates a validated 'Namespace' parameter that can be used in a dynamic parameter block.

        .EXAMPLE
            $Nodes = Get-Nodes
            Add-DynamicParameter -DynamicParameterDictionary $DynamicParameters -ParameterName 'Node' -ParameterType ([string[]]) -ValidateSet ([array]$Nodes.Name) -Alias 'Name' -ValueFromPipeline -ValueFromPipelineByPropertyName -HelpMessage 'The node to inspect.'
            # Adds a pipeline-friendly node selector based on the current cluster node inventory.
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True, Position=0, HelpMessage='Runtime defined parameter dictionary to add the parameter into.')]
            [System.Management.Automation.RuntimeDefinedParameterDictionary]$DynamicParameterDictionary,
            [Parameter(Mandatory=$True, Position=1, HelpMessage='Name of the dynamic parameter to create.')]
            [string]$ParameterName,
            [Parameter(Mandatory=$True, Position=2, HelpMessage='Type of the dynamic parameter.')]
            [Type]$ParameterType,
            [Parameter(Mandatory=$False, Position=3, HelpMessage='Help message text for the generated dynamic parameter.')]
            [string]$HelpMessage,
            [Parameter(Mandatory=$False, Position=4, HelpMessage='Parameter set name for the generated dynamic parameter.')]
            [string]$ParameterSetName,
            [Parameter(Mandatory=$False, Position=5, HelpMessage='Alias for the generated dynamic parameter.')]
            [string]$Alias,
            [Parameter(Mandatory=$False, Position=6, HelpMessage='Sets ValueFromPipeline on the generated dynamic parameter.')]
            [Switch]$ValueFromPipeline,
            [Parameter(Mandatory=$False, Position=7, HelpMessage='Sets ValueFromPipelineByPropertyName on the generated dynamic parameter.')]
            [Switch]$ValueFromPipelineByPropertyName,
            [Parameter(Mandatory=$False, Position=8, HelpMessage='ValidateSet values for the generated dynamic parameter.')]
            [string[]]$ValidateSet = $null,
            [Parameter(Mandatory=$False, Position=9, HelpMessage='ValidateRange bounds for the generated dynamic parameter.')]
            [string[]]$ValidateRange = $null,
            [Parameter(Mandatory=$False, Position=10, HelpMessage='Argument completer scriptblock for the generated dynamic parameter.')]
            [scriptblock]$ArgumentCompleter,
            [Parameter(Mandatory=$False, Position=11, HelpMessage='Additional attributes to apply to the generated dynamic parameter.')]
            [System.Attribute[]]$CustomAttributes = @(),
            [Parameter(Mandatory=$False, Position=12, HelpMessage='Marks the generated dynamic parameter as mandatory.')]
            [Switch]$Mandatory,
            [Parameter(Mandatory=$False, Position=13, HelpMessage='Default value assigned to the generated dynamic parameter.')]
            $DefaultValue = $null,
            [Parameter(Mandatory=$False, Position=14, HelpMessage='Position assigned to the generated dynamic parameter.')]
            [int]$Position = 0
        )

        $Attributes = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        $ParamAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttribute.Mandatory = $Mandatory
        $ParamAttribute.Position = $Position
        $ParamAttribute.ValueFromPipeline = $ValueFromPipeline
        $ParamAttribute.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName
        
        If([String]::IsNullOrEmpty($HelpMessage) -eq $False)
            {
                $ParamAttribute.HelpMessage = $HelpMessage
            }

        If([String]::IsNullOrEmpty($ParameterSetName) -eq $false)
            {
                $ParamAttribute.ParameterSetName = $ParameterSetName
            }

        $Attributes.Add($ParamAttribute)

        ForEach($Attribute in $CustomAttributes)
            {
                $Attributes.Add($Attribute)
            }

        If([String]::IsNullOrEmpty($Alias) -eq $false)
            {
                $AliasAttribute = New-Object System.Management.Automation.AliasAttribute($Alias)
                $Attributes.Add($AliasAttribute)
            }

        If($ValidateSet)
            {
                $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)
                $Attributes.Add($ValidateSetAttribute)
            }
        If($ValidateRange)
            {
                $ValidateRangeAttribute = New-Object System.Management.Automation.ValidateRangeAttribute($ValidateRange)
                $Attributes.Add($ValidateRangeAttribute)
            }
        If($ArgumentCompleter)
            {
                $CompleterAttribute = New-Object System.Management.Automation.ArgumentCompleterAttribute($ArgumentCompleter)
                $Attributes.Add($CompleterAttribute)
            }

        $RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::new($ParameterName, $ParameterType, $Attributes)
        If($null -ne $DefaultValue)
            {
                $RuntimeDefinedParameter.Value = $DefaultValue
            }

        $DynamicParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
    }