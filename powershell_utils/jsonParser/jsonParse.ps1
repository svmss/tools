$myJson = Get-Content test.json -Raw | ConvertFrom-Json
ForEach ($d in $myJson.scopeBindings) {
    if ($d.scopeTagName -eq "WUS-PPE-Stage") {
        Write-Output "Find Strings are : "
        ForEach ($e in $d.bindings) {
            Write-Output $e.find
        }
        Write-Output "========================================="
        Write-Output "Replace Strings are : "
        ForEach ($e in $d.bindings) {
            Write-Output $e.replaceWith
        }
    }
}
