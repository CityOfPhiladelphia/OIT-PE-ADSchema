<#
.Synopsis
   Gets attributes in an AD Schema
.DESCRIPTION
   Gets attributes in an AD Schema
.EXAMPLE
   Get-ADSchemaAttribute -class User -Attribute c*
.EXAMPLE
   Get-ADSchemaAttribute -class asTestClass -attribute asFavoriteColor
#>
Function Get-ADSchemaAttribute {
   param(
      [Parameter()]
      $Attribute = '*',

      [Parameter()]
      $Class = 'user',

      [Parameter()]
      $ComputerName,

      [ValidateNotNull()]
      [System.Management.Automation.PSCredential]
      [System.Management.Automation.Credential()]
      $Credential = [System.Management.Automation.PSCredential]::Empty
   )
   
   $FindClassParams = @{
      Class = $Class
   }
   if ($ComputerName) {
      $FindClassParams['ComputerName'] = $ComputerName
   }
   if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
      $FindClassParams['Credential'] = $Credential
   }

    $attributes = FindClassMandatoryProps @FindClassParams
    $attributes += FindClassOptionalProps @FindClassParams

    return $attributes | Where-Object {$_.Name -like $Attribute}
}