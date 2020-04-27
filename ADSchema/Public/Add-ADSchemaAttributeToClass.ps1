<#
.SYNOPSIS
    Adds an attribute to a class.

.DESCRIPTION
    Add a New Custom Class to an existing Structural Class in Active Directory.
    
    For example if you want to add attributes to the User Class:
    1. Create a new Auxiliary Class.
    2. Add Attributes to that new Auxiliary Class.
    3. Assign the new class as an Auxiliary Class to the User Class.

.PARAMETER AuxiliaryClass
    The class that will be holding the new attributes you are creating.
    This will be an Auxiliary Class of the structural class.

.PARAMETER Class
    The Structural Class you are adding an Auxiliary Class to. 

.EXAMPLE
    PS> Add-ADSchemaAuxiliaryClassToClass -AuxiliaryClass asTest -Class User
    Set the 'asTest' class as an Auxiliary Class of the User Class.
#>

Function Add-ADSchemaAttributeToClass {
    param(
        $Attribute,

        $Class,

        [Parameter()]
        $ComputerName,
  
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    # Stage splats for all commands that can accept ComputerName and Credential parameters
    $ADRootDSEParams = @{}
    $GetADObjectParams = @{}
    $SetADObjectParams = @{}
    # If ComputerName or Credential is defined, add them to all splats for commands that will accept them.
    if ($ComputerName) {
        $ADRootDSEParams['Server'] = $ComputerName
        $GetADObjectParams['Server'] = $ComputerName
        $SetADObjectParams['Server'] = $ComputerName
    }
    if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
        $ADRootDSEParams['Credential'] = $Credential
        $GetADObjectParams['Credential'] = $Credential
        $SetADObjectParams['Credential'] = $Credential
    }

    $schemaPath = (Get-ADRootDSE @ADRootDSEParams).schemaNamingContext

    $GetADObjectParams['SearchBase'] = $schemaPath
    $GetADObjectParams['Filter'] = "name -eq '$Class'"
    $Schema = Get-ADObject @GetADObjectParams

    $SetADObjectParams['Add'] = @{mayContain = $Attribute }
    $Schema | Set-ADObject @SetADObjectParams
}