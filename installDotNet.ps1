$temp=$env:TEMP
powershell.exe Invoke-WebRequest -OutFile $temp\ndp48-web.exe -Uri http://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/c9b8749dd99fc0d4453b2a3e4c37ba16/ndp48-web.exe

$args=('/passive', '/norestart')
Start-Process -Verb runas -FilePath "$temp\ndp48-web.exe" -ArgumentList $args -Wait
