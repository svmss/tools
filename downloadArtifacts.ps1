param( [string[]] $urls,[String] $mydir)
Import-Module BitsTransfer

Write-Output $mydir
if(!(Test-Path -path $mydir))  {
    New-Item -ItemType Directory -Force -Path $mydir
}

for ($i = 0; $i -le ($urls.length - 1); $i += 1) {
    Write-Debug $urls[$i]
    Write-Debug $urls[$i].Split('/')[-1]
    $fileName=Join-Path -Path $mydir -ChildPath $urls[$i].Split('/')[-1]    
    Write-Debug $fileName
    Start-BitsTransfer -Source $urls[$i] -Destination $fileName
}
