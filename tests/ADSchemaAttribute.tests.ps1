InModuleScope ADSchema {
    Describe "ADSchema Attribute Functions" {
        Context "Get-ADSchemaAttribute" {
            $password = ConvertTo-SecureString "TestPassword" -AsPlainText -Force
            $testcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('testuser',$password)

            Mock -ModuleName ADSchema FindClassMandatoryProps {} -Verifiable
            Mock -ModuleName ADSchema FindClassOptionalProps {} -Verifiable
            
            $result = Get-ADSchemaAttribute -Class User -Attribute CN

            It "exists as a function in the module" {
                (Get-Command Get-ADSchemaAttribute).count | should be 1
            }

            It "calls FindClassMandatoryProps and FindClassOptionalProps" {
                Assert-VerifiableMocks
            }

            <# It "calls FindClassMandatoryProps and FindClassOptionalProps when ComputerName and Credential exist" {
                Get-ADSchemaAttribute -Class User -Attribute CN -ComputerName dc -Credential $testcred
                Assert-VerifiableMocks
            }#>
        }

        Context "New-ADSchemaAttribute" {
            It "exists as a function in the module" {
                (Get-Command New-ADSchemaAttribute).count | should be 1
                
            }
        }

    }
}