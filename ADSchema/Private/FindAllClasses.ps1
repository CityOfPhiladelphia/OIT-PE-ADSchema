function FindAllClasses {
    $schema = [directoryservices.activedirectory.activedirectoryschema]::getcurrentschema()
    return $schema.FindAllClasses()
}