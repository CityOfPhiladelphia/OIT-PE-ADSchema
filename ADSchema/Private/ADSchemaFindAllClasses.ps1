function ADSchemaFindAllClasses {
    $schema = [directoryservices.activedirectory.activedirectoryschema]::getcurrentschema()
    return $schema.FindAllClasses()
}