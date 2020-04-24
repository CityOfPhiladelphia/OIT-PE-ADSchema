<#
.SYNOPSIS
   Gets classes in an AD Schema

.DESCRIPTION
   Use this function to list or search for existing classes in the Active Directory Schema

.PARAMETER Class
  The name of the class you want to search for. Supports wildcards

.EXAMPLE
   Get-ADSchemaClass -Name User
   
.EXAMPLE
   Get-ADSchemaClass com*
#>
Function Get-ADSchemaClass {
   param(
      [Parameter()]
      $Class = '*',

      [Parameter()]
      $ComputerName,

      [ValidateNotNull()]
      [System.Management.Automation.PSCredential]
      [System.Management.Automation.Credential()]
      $Credential = [System.Management.Automation.PSCredential]::Empty
   )

   $FindAllClassesParams = @{}
   if ($ComputerName) {
      $FindAllClassesParams['ComputerName'] = $ComputerName
   }
   if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
      $FindAllClassesParams['Credential'] = $Credential
   }

   $classes = FindAllClasses @FindAllClassesParams
   
   return $classes | Where-Object {$_.Name -like $Class}
}