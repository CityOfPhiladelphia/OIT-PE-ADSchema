function ADSchemaFindClass {
    param(
        [string]$Class
    )
    
    $schema = [directoryservices.activedirectory.activedirectoryschema]::getcurrentschema()
    
    return $schema.FindClass($Class)
}