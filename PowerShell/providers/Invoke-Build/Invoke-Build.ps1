@{
    "invoke"= {
            invoke-build @args
        };
    "isProject" = {
            return test-path "./.build.ps1";
        };
    "hasCommand" = {
        if(get-command invoke-build -ErrorAction SilentlyContinue){
            return $true;
        } else {
            return $false;
        }
    };
}
