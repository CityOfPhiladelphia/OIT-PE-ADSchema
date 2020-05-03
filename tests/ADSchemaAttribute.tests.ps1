InModuleScope ADSchema {
    Describe "ADSchema Attribute Functions" {
        $password = ConvertTo-SecureString "TestPassword" -AsPlainText -Force
        $testcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('testuser',$password)
        Mock -ModuleName ADSchema -Command Get-ADRootDSE { @{schemaNamingContext = 'CN=Schema,CN=Configuration,DC=example,DC=com'} }
        Mock -ModuleName ADSchema -Command Write-Warning {}

        It "Get-ADSchemaAttribute exists as a function in the module" {
            (Get-Command Get-ADSchemaAttribute).count | should be 1
        }

        It "New-ADSchemaAttribute exists as a function in the module" {
            (Get-Command New-ADSchemaAttribute).count | should be 1
        }

        Context "Get-ADSchemaAttribute without credentials" {  
            Mock -ModuleName ADSchema -Command FindClassMandatoryProps {} -Verifiable -ParameterFilter {$Class -eq 'User'}
            Mock -ModuleName ADSchema -Command FindClassOptionalProps {} -Verifiable -ParameterFilter {$Class -eq 'User'}  
            $result = Get-ADSchemaAttribute -Class User -Attribute CN

            It "calls FindClassMandatoryProps and FindClassOptionalProps" {
                Assert-VerifiableMock
            }
        }

        Context "Get-ADSchemaAttribute with ComputerName and Credential" {
            Mock -ModuleName ADSchema -Command FindClassMandatoryProps {} -Verifiable -ParameterFilter {$Class -eq 'User' -and $ComputerName -eq 'dc' -and $Credential -eq $testcred}
            Mock -ModuleName ADSchema -Command FindClassOptionalProps {} -Verifiable -ParameterFilter {$Class -eq 'User' -and $ComputerName -eq 'dc' -and $Credential -eq $testcred}
            $result = Get-ADSchemaAttribute -Class User -Attribute CN -ComputerName dc -Credential $testcred

            It "calls FindClassMandatoryProps and FindClassOptionalProps" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaAttribute without credentials" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter {$Name -eq 'as-favoriteColor' -and $Description -eq 'Favorite Color' -and $IsSingleValued -eq $true -and $AttributeType -eq 'String' -and $AttributeID -eq '1.2.840.113556.1.8000.2554.64653.53965'}
            $result = New-ADSchemaAttribute -Name 'as-favoriteColor' -Description 'Favorite Color' -IsSingleValued $true -AttributeType 'String' -AttributeID '1.2.840.113556.1.8000.2554.64653.53965' -Confirm:$false

            It "creates a new AD object" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaAttribute with ComputerName and Credential" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter {$Name -eq 'as-favoriteColor' -and $Description -eq 'Favorite Color' -and $IsSingleValued -eq $true -and $AttributeType -eq 'String' -and $AttributeID -eq '1.2.840.113556.1.8000.2554.64653.53965' -and $ComputerName -eq 'dc' -and $Credential -eq $testcred}
            $result = New-ADSchemaAttribute -Name 'as-favoriteColor' -Description 'Favorite Color' -IsSingleValued $true -AttributeType 'String' -AttributeID '1.2.840.113556.1.8000.2554.64653.53965' -ComputerName 'dc' -Credential $testcred -Confirm:$false

            It "creates a new AD object" {
                Assert-VerifiableMock
            }
        }

        Context "New-ADSchemaAttribute ShouldProcess" {
            Mock -ModuleName ADSchema -Command New-ADObject {} -Verifiable -ParameterFilter {$Name -eq 'as-favoriteColor' -and $Description -eq 'Favorite Color' -and $IsSingleValued -eq $true -and $AttributeType -eq 'String' -and $AttributeID -eq '1.2.840.113556.1.8000.2554.64653.53965'}
            
            It "does not creates a new AD object" {
                $result = New-ADSchemaAttribute -Name 'as-favoriteColor' -Description 'Favorite Color' -IsSingleValued $true -AttributeType 'String' -AttributeID '1.2.840.113556.1.8000.2554.64653.53965' -WhatIf
                Assert-MockCalled -CommandName 'New-ADObject' -Exactly -Times 0
            }
        }
    }
}