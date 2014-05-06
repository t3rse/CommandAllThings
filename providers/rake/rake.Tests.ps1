﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$sampleProject = "$here/../../samples/rakeSample/"

$provider = Create-Provider
write-host ($provider | gm)

Describe "When in a rake project" {


    Context "when loading the provider" {
        

        It "Should have loaded" {
            $provider | should not be $null
        }

        It "Should have loaded" {
            $provider.invoke | should not be $null
        }

    }

    
    Mock Get-ChildItem {return " $sampleProject/rakefile" }


    Context "And rake is not installed" {
        Mock Where-Lookup-Command { return $null; }

        $hasCommand = $provider.hasCommand();

        It "Should not exist" {
            $hasCommand | Should Be $false;
        }

    }

    
    Context "rake IS installed" {
        Mock Where-Lookup-Command { return "C:\Users\UserA\AppData\Roaming\npm\rake.cmd"; }

        $hasCommand = $provider.hasCommand();

        It "Should not exist" {
            $hasCommand | Should Be $true;
        }

        It "Should NOT throw an exception because rakefile should exist." {
            { $provider.isProject() } | Should Not Throw
        }

        It "Should be a project." {

            try {
                pushd $sampleProject

                $provider.isProject() | Should Be $true
            } finally{
                popd
            }
        }

        It "Should invoke rake test" {
            
            try {
                pushd $sampleProject


                $result = $provider.invoke();
                [string]::Join([System.Environment]::NewLine,$result) | should Match "Hello rake"
            } finally{
                popd
            }
        }

    }
}


Describe "When NOT in a rake project" {


    Mock Get-ChildItem {return $null }

    Context "rake IS installed" {
        Mock Where-Lookup-Command { return "C:\Ruby193\bin\rake
C:\Ruby193\bin\rake.bat"; }

        It "Should not exist" {
             $provider.hasCommand() | Should Be $true;
        }

        It "Should report not in a rake project." {
            $provider.isProject() | Should Be $false
        }
    }
}
