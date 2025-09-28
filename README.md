Please only use Blame or Raw.

Repo will automatically be updated.

PowerShell Code for Windows 11:
```
$reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

$searchBuild = $reg.UBR

# URL auslesen
$url = "https://raw.githubusercontent.com/Alitai12/Windows-Updatelist/refs/heads/main/Windows%2011%2023H2%2022631.txt"
$response = Invoke-WebRequest -Uri $url
$pageText = $response.Content

# Nach Build suchen
$line = $pageText -split "`n" | Where-Object { $_ -match "$searchBuild" }

$info = [PSCustomObject]@{
    ProductName    = $reg.ProductName
    DisplayVersion = $reg.DisplayVersion
    ServicingChannel = $line
}

$info | Format-Table -Wrap -AutoSize
```

PowerShell Output:
```
ProductName           DisplayVersion ServicingChannel                                                        
-----------           -------------- ----------------                                                        
Windows 11 Enterprise 23H2           ﻿General Availability Channel 2025-09 B 2025-09-09 22631.5909 KB5065431
```

PowerShell for Windows Server 2019:

```
$reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

$searchBuild = $reg.UBR

# URL auslesen
$url = "https://raw.githubusercontent.com/Alitai12/Windows-Updatelist/refs/heads/main/Windows%20Server%202019%2017763.txt"
$response = Invoke-WebRequest -Uri $url
$pageText = $response.Content

# Nach Build suchen
$line = $pageText -split "`n" | Where-Object { $_ -match "$searchBuild" }

$info = [PSCustomObject]@{
    ProductName    = $reg.ProductName
    ReleaseId      = $reg.ReleaseId
    BuildNumber    = "$($reg.CurrentBuild).$($reg.UBR)"
    ServicingChannel = $line
}

$info | Format-Table -Wrap -AutoSize
```

PowerShell for all Servers:
```
$urls = @(
    "https://raw.githubusercontent.com/Alitai12/Windows-Updatelist/refs/heads/main/Windows%20Server%202016%2014393.txt",
    "https://raw.githubusercontent.com/Alitai12/Windows-Updatelist/refs/heads/main/Windows%20Server%202019%2017763.txt",
    "https://raw.githubusercontent.com/Alitai12/Windows-Updatelist/refs/heads/main/Windows%20Server%202022%2020348.txt",
    "https://raw.githubusercontent.com/Alitai12/Windows-Updatelist/refs/heads/main/Windows%20Server%202025%2026100.txt"
)

# Inhalte abrufen und in einer Variablen speichern
$contents = foreach ($url in $urls) {
    Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
}

$reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

$searchBuild = "$($reg.CurrentBuild).$($reg.UBR)"
$line = $contents -split "`n" | Where-Object { $_ -match "$searchBuild" }
$regex = '(\d{4}-\d{2}\s+(?:A|B|C|D|E|OOB))\s+(\d{4}-\d{2}-\d{2}).*?(KB\d+)'

if ($line -match $regex) {
    $Updatetype   = $matches[1]  # z. B. "2025-09 B"
    $Date    = $matches[2]  # z. B. "2025-09-09"
    $KB        = $matches[3]  # z. B. "KB5065429"
}

$info = [PSCustomObject]@{
    ProductName    = $reg.ProductName
    ReleaseId      = $reg.ReleaseId
    BuildNumber    = "$($reg.CurrentBuild).$($reg.UBR)"
    'Update type'  = $Updatetype
    Date           = $Date
    KB             = $KB
}

$info | Format-Table -Wrap -AutoSize
```
