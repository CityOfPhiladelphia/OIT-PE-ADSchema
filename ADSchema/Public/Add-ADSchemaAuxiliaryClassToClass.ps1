<#
.SYNOPSIS
    Adds an Auxiliary Class to a Structural Class.

.DESCRIPTION
    Add a new Custom Class to an existing Structural Class in Active Directory.
    
    For example if you want to add attributes to the user class, you should:
    
    1) Create a new Auxiliary Class.
    2) Add attributes to that Auxiliary Class.
    3) Finally assign the New Class as an Auxiliary Class to the User Class.

.PARAMETER AuxiliaryClass
    The class that will be holding the new attributes you are creating.
    This will be an auxiliary class of the structural class.

.PARAMETER Class
    The structural class you are adding an Auxiliary Class to.. 

.EXAMPLE
    PS> Add-ADSchemaAuxiliaryClassToClass -AuxiliaryClass asTest -Class User
    Set the asTest class as an aux class of the User class.

#>

Function Add-ADSchemaAuxiliaryClassToClass {
    param(
        [Parameter()]
        $AuxiliaryClass,

        [Parameter()]
        $Class,

        [Parameter()]
        $ComputerName,
  
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    # Stage splats for all commands that can accept ComputerName and Credential parameters
    $ADRootDSEParams = @{ }
    $GetADObjectParams1 = @{ }
    $GetADObjectParams2 = @{ }
    $SetADObjectParams = @{ }
    # If ComputerName or Credential is defined, add them to all splats for commands that will accept them.
    if ($ComputerName) {
        $ADRootDSEParams['ComputerName'] = $ComputerName
        $GetADObjectParams1['ComputerName'] = $ComputerName
        $GetADObjectParams2['ComputerName'] = $ComputerName
        $SetADObjectParams['ComputerName'] = $ComputerName
    }
    if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
        $ADRootDSEParams['Credential'] = $Credential
        $GetADObjectParams1['Credential'] = $Credential
        $GetADObjectParams2['ComputerName'] = $ComputerName
        $SetADObjectParams['Credential'] = $Credential
    }

    $schemaPath = (Get-ADRootDSE @ADRootDSEParams).schemaNamingContext

    $GetADObjectParams1['SearchBase'] = $schemaPath
    $GetADObjectParams1['Filter'] = "name -eq '$AuxiliaryClass'"
    $GetADObjectParams1['Properties'] = 'governsID'
    $auxClass = Get-ADObject @GetADObjectParams1

    $GetADObjectParams2['SearchBase'] = $schemaPath
    $GetADObjectParams2['Filter'] = "name -eq '$AuxiliaryClass'"
    $classToAddTo = Get-ADObject @GetADObjectParams2

    $SetADObjectParams['Add'] = @{ auxiliaryClass = $($auxClass.governsID) }
    $classToAddTo | Set-ADObject @SetADObjectParams
}