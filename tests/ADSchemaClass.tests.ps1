InModuleScope ADSchema {
    Describe "ADSchema Class Functions" {
        $password = ConvertTo-SecureString "TestPassword" -AsPlainText -Force
        $testcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('testuser',$password)
        $ClassOID = '1.2.840.113556.1.8000.2554.64653.53965'
        $ClassDescription = 'Host custom user attributes'
        $SchemaPath = 'CN=Schema,CN=Configuration,DC=example,DC=com'
        $attributes = @{
            governsId           = $ClassOID
            adminDescription    = $ClassDescription
            objectClass         = 'classSchema'
            ldapDisplayName     = 'asPerson'
            adminDisplayName    = 'asPerson'
            objectClassCategory = 3
            systemOnly          = $FALSE
            # subclassOf: top
            subclassOf          = "2.5.6.0"
            # rdnAttId: cn
            rdnAttId            = "2.5.4.3"
        }

        Mock -ModuleName ADSchema -Command Get-ADRootDSE { @{ schemaNamingContext = $SchemaPath } }
        Mock -ModuleName ADSchema -Command Write-Warning {}
        

        It "Get-ADSchemaClass exists as a function in the module" {
            (Get-Command Get-ADSchemaClass).count | should be 1
        }

        It "New-ADSchemaClass exists as a function in the module" {
            (Get-Command New-ADSchemaClass).count | should be 1        
        }

        It "Add-ADSchemaAuxiliaryClassToClass exists as a function in the module" {
            (Get-Command Add-ADSchemaAuxiliaryClassToClass).Count | Should Be 1
        }

        Context "Get-ADSchemaClass without credentials" {        
            Mock -ModuleName ADSchema FindAllClasses {} -Verifiable  
            $result = Get-ADSchemaClass -Class 'User'

            It "calls FindAllClasses" {
                Assert-VerifiableMock
            }
        }

        Context "Get-ADSchemaClass with ComputerName and Credential" {
            Mock -ModuleName ADSchema FindAllClasses {} -Verifiable -ParameterFilter { $ComputerName -eq 'dc' -and $Credential -eq $testcred }      
            $result = Get-ADSchemaClass -Class 'User' -ComputerName 'dc' -Credential $testcred

            It "calls FindAllClasses" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaClass without credentials" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter { $Name -eq 'asPerson' -and $Type -eq 'classSchema' -and $Path -eq $SchemaPath -and $OtherAttributes -eq $attributes }
            $result = New-ADSchemaClass -Name 'asPerson' -Description $ClassDescription -Category 'Auxiliary' -AttributeID $ClassOID -Confirm:$false

            It "creates a new AD object" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaClass with ComputerName and Credential" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter { $Name -eq 'asPerson' -and $Type -eq 'classSchema' -and $Path -eq $SchemaPath -and $OtherAttributes -eq $attributes -and $Server -eq 'dc' -and $Credential -eq $testcred }
            $result = New-ADSchemaClass -Name 'asPerson' -Description $ClassDescription -Category 'Auxiliary' -AttributeID $ClassOID -ComputerName 'dc' -Credential $testcred -Confirm:$false

            It "creates a new AD object" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaClass ShouldProcess" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter { $Name -eq 'asPerson' -and $Type -eq 'classSchema' -and $Path -eq $SchemaPath -and $OtherAttributes -eq $attributes }
            $result = New-ADSchemaClass -Name 'asPerson' -Description $ClassDescription -Category 'Auxiliary' -AttributeID $ClassOID -WhatIf
            
            It "does not create a new AD object" {
                Assert-MockCalled -CommandName 'New-ADObject' -Exactly -Times 0
            }
        }

        Context "Add-ADSchemaAuxiliaryClassToClass without credentials" {
            Mock -ModuleName ADSchema -Command Get-ADObject -ParameterFilter { $SearchBase -eq $SchemaPath -and $Filter -eq "name -eq 'asPerson'" -and $Properties -eq 'governsID' } -MockWith { @{ DistinguishedName = 'CN=asPerson,CN=Schema,CN=Configuration,DC=example,DC=com'; GovernsID = $ClassOID } }
            Mock -ModuleName ADSchema -Command Get-ADObject -ParameterFilter { $SearchBase -eq $SchemaPath -and $Filter -eq "name -eq 'User'" } -MockWith { @{ DistinguishedName = 'CN=User,CN=Schema,CN=Configuration,DC=example,DC=com' } }
            Mock -ModuleName ADSchema -Command Set-ADObject {} -Verifiable
            $result = Add-ADSchemaAuxiliaryClassToClass -AuxiliaryClass 'asPerson' -Class 'User'

            It "adds an attribute to a class" {               
                Assert-VerifiableMock
            }
        }

        Context "Add-ADSchemaAuxiliaryClassToClass with ComputerName and Credential" {
            Mock -ModuleName ADSchema -Command Get-ADObject -ParameterFilter { $SearchBase -eq $SchemaPath -and $Filter -eq "name -eq 'asPerson'" -and $Properties -eq 'governsID' -and $Server -eq 'dc' -and $Credential -eq $testcred } -MockWith { @{ DistinguishedName = 'CN=asPerson,CN=Schema,CN=Configuration,DC=example,DC=com'; GovernsID = $ClassOID } }
            Mock -ModuleName ADSchema -Command Get-ADObject -ParameterFilter { $SearchBase -eq $SchemaPath -and $Filter -eq "name -eq 'User'" -and $Server -eq 'dc' -and $Credential -eq $testcred } -MockWith { @{ DistinguishedName = 'CN=User,CN=Schema,CN=Configuration,DC=example,DC=com' } }
            Mock -ModuleName ADSchema -Command Set-ADObject {} -Verifiable -ParameterFilter { $Server -eq 'dc' -and $Credential -eq $testcred }

            It "adds an attribute to a class" {
                $result = Add-ADSchemaAuxiliaryClassToClass -AuxiliaryClass 'asPerson' -Class 'User' -ComputerName 'dc' -Credential $testcred
                Assert-VerifiableMock
            }
        }
    }
}