InModuleScope ADSchema {
    Describe "ADSchema Attribute Functions" {
        $password = ConvertTo-SecureString "TestPassword" -AsPlainText -Force
        $testcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('testuser',$password)

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


    }
}