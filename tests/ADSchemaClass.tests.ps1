InModuleScope ADSchema {
    Describe "ADSchema Class Functions" {
        $password = ConvertTo-SecureString "TestPassword" -AsPlainText -Force
        $testcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('testuser',$password)

        Mock -ModuleName ADSchema FindAllClasses {} -Verifiable

        It "Get-ADSchemaClass exists as a function in the module" {
            (Get-Command Get-ADSchemaClass).count | should be 1
        }

        It "New-ADSchemaClass exists as a function in the module" {
            (Get-Command New-ADSchemaClass).count | should be 1        
        }

        Context "Get-ADSchemaClass without credentials" {            
            $result = Get-ADSchemaClass -Class User

            It "calls FindAllClasses" {
                Assert-VerifiableMock
            }
        }

        Context "Get-ADSchemaClass with ComputerName and Credential" {            
            $result = Get-ADSchemaClass -Class User -ComputerName dc -Credential $testcred

            It "calls FindAllClasses" {
                Assert-VerifiableMock
            }
        }

    }
}