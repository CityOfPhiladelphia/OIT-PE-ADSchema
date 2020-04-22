function GetADSchema {
    return [directoryservices.activedirectory.activedirectoryschema]::getcurrentschema()
}