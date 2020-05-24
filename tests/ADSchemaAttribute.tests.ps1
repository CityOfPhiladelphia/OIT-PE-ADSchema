InModuleScope ADSchema {
    Describe "ADSchema Attribute Functions" {
        $password = ConvertTo-SecureString "TestPassword" -AsPlainText -Force
        $testcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('testuser',$password)
        $AttributeOID = '1.2.840.113556.1.8000.2554.64653.53965'
        $SchemaPath = 'CN=Schema,CN=Configuration,DC=example,DC=com'
        $attributes = @{
            lDAPDisplayName  = 'as-FavoriteColor'
            attributeId      = $AttributeOID
            oMSyntax         = 20
            attributeSyntax  = '2.5.5.4'
            isSingleValued   = $true
            adminDescription = 'Favorite Color'
            searchflags      = 1
        }
        Mock -ModuleName ADSchema -Command Get-ADRootDSE { @{ schemaNamingContext = $SchemaPath } }
        Mock -ModuleName ADSchema -Command Write-Warning {}

        It "Get-ADSchemaAttribute exists as a function in the module" {
            (Get-Command Get-ADSchemaAttribute).Count | Should Be 1
        }

        It "New-ADSchemaAttribute exists as a function in the module" {
            (Get-Command New-ADSchemaAttribute).Count | Should Be 1
        }

        It "Add-ADSchemaAttributeToClass exists as a function in the module" {
            (Get-Command Add-ADSchemaAttributeToClass).Count | Should Be 1
        }

        Context "Get-ADSchemaAttribute without credentials" {  
            Mock -ModuleName ADSchema -Command FindClassMandatoryProps {} -Verifiable -ParameterFilter { $Class -eq 'User' }
            Mock -ModuleName ADSchema -Command FindClassOptionalProps {} -Verifiable -ParameterFilter { $Class -eq 'User' }  
            $result = Get-ADSchemaAttribute -Class User -Attribute CN

            It "calls FindClassMandatoryProps and FindClassOptionalProps" {
                Assert-VerifiableMock
            }
        }

        Context "Get-ADSchemaAttribute with ComputerName and Credential" {
            Mock -ModuleName ADSchema -Command FindClassMandatoryProps {} -Verifiable -ParameterFilter { $Class -eq 'User' -and $ComputerName -eq 'dc' -and $Credential -eq $testcred }
            Mock -ModuleName ADSchema -Command FindClassOptionalProps {} -Verifiable -ParameterFilter { $Class -eq 'User' -and $ComputerName -eq 'dc' -and $Credential -eq $testcred }
            $result = Get-ADSchemaAttribute -Class User -Attribute CN -ComputerName dc -Credential $testcred

            It "calls FindClassMandatoryProps and FindClassOptionalProps" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaAttribute without credentials" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter { $Name -eq 'as-favoriteColor' -and $Type -eq 'attributeSchema' -and $Path -eq $SchemaPath -and $OtherAttributes -eq $attributes }
            $result = New-ADSchemaAttribute -Name 'as-favoriteColor' -Description 'Favorite Color' -IsSingleValued $true -AttributeType 'String' -AttributeID $AttributeOID -Confirm:$false

            It "creates a new AD object" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaAttribute with ComputerName and Credential" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter { $Name -eq 'as-favoriteColor' -and $Type -eq 'attributeSchema' -and $Path -eq $SchemaPath -and $OtherAttributes -eq $attributes -and $ComputerName -eq 'dc' -and $Credential -eq $testcred }
            $result = New-ADSchemaAttribute -Name 'as-favoriteColor' -Description 'Favorite Color' -IsSingleValued $true -AttributeType 'String' -AttributeID $AttributeOID -ComputerName 'dc' -Credential $testcred -Confirm:$false

            It "creates a new AD object" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaAttribute ShouldProcess" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter { $Name -eq 'as-favoriteColor' -and $Type -eq 'attributeSchema' -and $Path -eq $SchemaPath -and $OtherAttributes -eq $attributes }
            $result = New-ADSchemaAttribute -Name 'as-favoriteColor' -Description 'Favorite Color' -IsSingleValued $true -AttributeType 'String' -AttributeID $AttributeOID -WhatIf
            
            It "does not create a new AD object" {
                Assert-MockCalled -CommandName 'New-ADObject' -Exactly -Times 0
            }
        }

        Context "Add-ADSchemaAttributeToClass without credentials" {
            Mock -ModuleName ADSchema -Command Get-ADObject { @{ DistinguishedName = 'CN=User,CN=Schema,CN=Configuration,DC=example,DC=com' } }
            Mock -ModuleName ADSchema -Command Set-ADObject {}
            $result = Add-ADSchemaAttributeToClass -Attribute 'as-favoriteColor' -Class 'User'

            It "adds an attribute to a class" {               
                Assert-MockCalled -CommandName 'Set-ADObject' -Times 1
            }
        }

        Context "Add-ADSchemaAttributeToClass with ComputerName and Credential" {
            Mock -ModuleName ADSchema -Command Get-ADObject { @{ DistinguishedName = 'CN=User,CN=Schema,CN=Configuration,DC=example,DC=com' } }
            Mock -ModuleName ADSchema -Command Set-ADObject {} -Verifiable -ParameterFilter {$Server -eq 'dc' -and $Credential -eq $testcred}

            It "adds an attribute to a class" {
                $result = Add-ADSchemaAttributeToClass -Attribute 'as-favoriteColor' -Class 'User' -ComputerName 'dc' -Credential $testcred
                Assert-VerifiableMock
            }
        }
    }
}