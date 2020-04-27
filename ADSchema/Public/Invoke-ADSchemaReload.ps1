<#
.SYNOPSIS
    Reloads the Active Directory Schema
.DESCRIPTION
    After the schema has been updated, it needs to be reloaded so your updates
    can be seen immediately. 
.EXAMPLE
    PS C:\> Invoke-ADSchemaReload
#>

Function Invoke-ADSchemaReload {
    param(
        [Parameter()]
        $ComputerName,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    $ADRootDSEParams = @{}
    if ($ComputerName) {
        $ADRootDSEParams['ComputerName'] = $ComputerName
    }
    if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
        $ADRootDSEParams['Credential'] = $Credential
    }

    $dse =  Get-ADRootDSE @ADRootDSEParams
    $dse.schemaUpdateNow = $true
}