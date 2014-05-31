$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$provider = . "$here\$sut"

$sampleProject = "$here/../../../samples/Invoke-BuildSample/"
pushd $sampleProject
popd

Describe "When in a Invoke-Build project" {

    Context "when loading the provider" {
        

        It "Should have loaded" {
            $provider | should not be $null
        }

        It "Should have invoke script block" {
            $provider.invoke | should not be $null
        }

        It "Should have hasCommand script block" {
            $provider.hasCommand | should not be $null
        }

        It "Should have isProject script block" {
            $provider.isProject | should not be $null
        }

    }
    

    
    Mock Get-ChildItem {return "$sampleProject/.build.ps1" }


    Context "And Invoke-Build is not installed" {

        $hasCommand = & $provider.hasCommand;

        It "Should not exist" {
            $hasCommand | Should Be $false;
        }

    }

    Context "Invoke-Build IS installed" {

        Mock Invoke-Build {}

        $hasCommand = & $provider.hasCommand;

        It "Should exist" {
            $hasCommand | Should Be $true;
        }

        It "Should be a project." {

            try {
                pushd $sampleProject

                & $provider.isProject | Should Be $true
            } finally{
                popd
            }
        }
    }

}


Describe "When NOT in a Invoke-Build project" {

    Mock Invoke-Build { return "" }

    Mock Get-ChildItem { return $null }

    Context "Invoke-Build IS installed" {

        It "Should not exist" {
             & $provider.hasCommand | Should Be $true;
        }

        It "Should report not in a gulp project." {
            & $provider.isProject | Should Be $false
        }
    }
}
