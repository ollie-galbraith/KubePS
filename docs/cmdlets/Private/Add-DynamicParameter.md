## Add-DynamicParameter

### Description

Creates and registers a dynamic PowerShell parameter in a RuntimeDefinedParameterDictionary so advanced functions can validate input against live data such as namespace names, pod names, or node names without hardcoding those values in the static param block.
This helper is used throughout KubePS to build dynamic parameters for context-aware commands that need to reflect the current cluster state at runtime, including validation sets, aliases, default values, mandatory flags, and custom completion metadata.

---

```
Add-DynamicParameter

	[-DynamicParameterDictionary      <System.Management.Automation.RuntimeDefinedParameterDictionary[ ]>]
	[-ParameterName                                                                    <System.String[ ]>]
	[-ArgumentCompleter                                     <System.Management.Automation.ScriptBlock[ ]>]
	[-CustomAttributes                                                            <System.Attribute[][ ]>]
	[-Mandatory                                         <System.Management.Automation.SwitchParameter[ ]>]
	[-DefaultValue                                                                     <System.Object[ ]>]
	[-Position                                                                          <System.Int32[ ]>]
	[-ParameterType                                                                      <System.Type[ ]>]
	[-HelpMessage                                                                      <System.String[ ]>]
	[-ParameterSetName                                                                 <System.String[ ]>]
	[-Alias                                                                            <System.String[ ]>]
	[-ValueFromPipeline                                 <System.Management.Automation.SwitchParameter[ ]>]
	[-ValueFromPipelineByPropertyName                   <System.Management.Automation.SwitchParameter[ ]>]
	[-ValidateSet                                                                    <System.String[][ ]>]
	[-ValidateRange                                                                  <System.String[][ ]>]
	[<CommonParameters>]

```

---

### Source Code
[Add-DynamicParameter.ps1](../../Private/Add-DynamicParameter.ps1)

### Examples

#### Example 1
```powershell
$DynamicParameters = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
Add-DynamicParameter -DynamicParameterDictionary $DynamicParameters -ParameterName 'Namespace' -ParameterType ([string]) -Mandatory -ValidateSet @('default', 'kube-system') -HelpMessage 'Namespace to query.'
# Creates a validated 'Namespace' parameter that can be used in a dynamic parameter block.
```
#### Example 2
```powershell
$Nodes = Get-Nodes
Add-DynamicParameter -DynamicParameterDictionary $DynamicParameters -ParameterName 'Node' -ParameterType ([string[]]) -ValidateSet ([array]$Nodes.Name) -Alias 'Name' -ValueFromPipeline -ValueFromPipelineByPropertyName -HelpMessage 'The node to inspect.'
# Adds a pipeline-friendly node selector based on the current cluster node inventory.
```

---

### Parameters

#### -Alias

Alias for the generated dynamic parameter.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -ArgumentCompleter

Argument completer scriptblock for the generated dynamic parameter.

|           |                                          |
| --------- | ---------------------------------------- |
| Type      | System.Management.Automation.ScriptBlock |
| Mandatory | False                                    |


#### -CustomAttributes

Additional attributes to apply to the generated dynamic parameter.

|              |                    |
| ------------ | ------------------ |
| Type         | System.Attribute[] |
| Mandatory    | False              |
| DefaultValue | @()                |


#### -DefaultValue

Default value assigned to the generated dynamic parameter.

|              |               |
| ------------ | ------------- |
| Type         | System.Object |
| Mandatory    | False         |
| DefaultValue | $null         |


#### -DynamicParameterDictionary

Runtime defined parameter dictionary to add the parameter into.

|           |                                                                |
| --------- | -------------------------------------------------------------- |
| Type      | System.Management.Automation.RuntimeDefinedParameterDictionary |
| Mandatory | True                                                           |


#### -HelpMessage

Help message text for the generated dynamic parameter.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -Mandatory

Marks the generated dynamic parameter as mandatory.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -ParameterName

Name of the dynamic parameter to create.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | True          |


#### -ParameterSetName

Parameter set name for the generated dynamic parameter.

|           |               |
| --------- | ------------- |
| Type      | System.String |
| Mandatory | False         |


#### -ParameterType

Type of the dynamic parameter.

|           |             |
| --------- | ----------- |
| Type      | System.Type |
| Mandatory | True        |


#### -Position

Position assigned to the generated dynamic parameter.

|              |              |
| ------------ | ------------ |
| Type         | System.Int32 |
| Mandatory    | False        |
| DefaultValue | 0            |


#### -ValidateRange

ValidateRange bounds for the generated dynamic parameter.

|              |                 |
| ------------ | --------------- |
| Type         | System.String[] |
| Mandatory    | False           |
| DefaultValue | $null           |


#### -ValidateSet

ValidateSet values for the generated dynamic parameter.

|              |                 |
| ------------ | --------------- |
| Type         | System.String[] |
| Mandatory    | False           |
| DefaultValue | $null           |


#### -ValueFromPipeline

Sets ValueFromPipeline on the generated dynamic parameter.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |


#### -ValueFromPipelineByPropertyName

Sets ValueFromPipelineByPropertyName on the generated dynamic parameter.

|           |                                              |
| --------- | -------------------------------------------- |
| Type      | System.Management.Automation.SwitchParameter |
| Mandatory | False                                        |
