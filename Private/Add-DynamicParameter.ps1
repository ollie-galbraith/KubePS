Function Add-DynamicParameter
    {
        <#
        .SYNOPSIS
        Adds a dynamic parameter to a PowerShell function or script. For use in advanced functions or scripts with dynamic parameters defined in the DynamicParameters() block.
        For more examples of how to use this function, see the DynamicParam{} block in the [Start-AnsibleJobTemplate](../../../LTF-Ansible/Public/Controller/Job/Start-AnsibleJobTemplate.ps1) cmdlet in the LTF-AnsiblePS module.
        .EXAMPLE
        # Add a dynamic parameter named "ExampleParam" of type string
        Add-DynamicParameter -DynamicParameterDictionary $DynamicParameters -ParameterName "ExampleParam" -ParameterType [string]
        #>

        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$True, Position = 0, HelpMessage = 'Runtime defined parameter dictionary to add the parameter into.')]
            [System.Management.Automation.RuntimeDefinedParameterDictionary]$DynamicParameterDictionary,
            [Parameter(Mandatory=$True, Position = 1, HelpMessage = 'Name of the dynamic parameter to create.')]
            [string]$ParameterName,
            [Parameter(Mandatory=$True, Position = 2, HelpMessage = 'Type of the dynamic parameter.')]
            [Type]$ParameterType,
            [Parameter(Mandatory=$False, Position = 3, HelpMessage = 'Help message text for the generated dynamic parameter.')]
            [string]$HelpMessage,
            [Parameter(Mandatory=$False, Position = 4, HelpMessage = 'Parameter set name for the generated dynamic parameter.')]
            [string]$ParameterSetName,
            [Parameter(Mandatory=$False, Position = 5, HelpMessage = 'Alias for the generated dynamic parameter.')]
            [string]$Alias,
            [Parameter(Mandatory=$False, Position = 6, HelpMessage = 'Sets ValueFromPipeline on the generated dynamic parameter.')]
            [Switch]$ValueFromPipeline,
            [Parameter(Mandatory=$False, Position = 7, HelpMessage = 'Sets ValueFromPipelineByPropertyName on the generated dynamic parameter.')]
            [Switch]$ValueFromPipelineByPropertyName,
            [Parameter(Mandatory=$False, Position = 8, HelpMessage = 'ValidateSet values for the generated dynamic parameter.')]
            [string[]]$ValidateSet = $null,
            [Parameter(Mandatory=$False, Position = 9, HelpMessage = 'ValidateRange bounds for the generated dynamic parameter.')]
            [string[]]$ValidateRange = $null,
            [Parameter(Mandatory=$False, Position = 10, HelpMessage = 'Argument completer scriptblock for the generated dynamic parameter.')]
            [scriptblock]$ArgumentCompleter,
            [Parameter(Mandatory=$False, Position = 11, HelpMessage = 'Additional attributes to apply to the generated dynamic parameter.')]
            [System.Attribute[]]$CustomAttributes = @(),
            [Parameter(Mandatory=$False, Position = 12, HelpMessage = 'Marks the generated dynamic parameter as mandatory.')]
            [Switch]$Mandatory,
            [Parameter(Mandatory=$False, Position = 13, HelpMessage = 'Default value assigned to the generated dynamic parameter.')]
            $DefaultValue = $null,
            [Parameter(Mandatory=$False, Position = 14, HelpMessage = 'Position assigned to the generated dynamic parameter.')]
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