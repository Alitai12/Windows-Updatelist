Please only use Blame or Raw.

Repo will automatically be updated.

PowerShell Code for Windows 10:
```
$reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

$searchBuild = $reg.UBR

# URL auslesen
$url = "https://raw.githubusercontent.com/Alitai12/Windows-Updatelist/refs/heads/main/Windows%2010%2022H2%2019045.txt"
$response = Invoke-WebRequest -Uri $url
$pageText = $response.Content

# Nach Build suchen
$line = $pageText -split "`n" | Where-Object { $_ -match "$searchBuild" }

$info = [PSCustomObject]@{
    ProductName    = $reg.ProductName
    DisplayVersion = $reg.DisplayVersion
    BuildNumber    = "$($reg.CurrentBuild).$($reg.UBR)"
    ServicingChannel = $line
}

$info | Format-Table -Wrap -AutoSize
```

PowerShell Output:
```
ProductName           DisplayVersion BuildNumber ServicingChannel                                                        
-----------           -------------- ----------- ----------------                                                        
Windows 10 Enterprise 22H2           19045.6216  General Availability Channel 2025-08 B 2025-08-12 19045.6216 KB5063709
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
    ReleaseId = $reg.ReleaseId
    BuildNumber    = "$($reg.CurrentBuild).$($reg.UBR)"
    ServicingChannel = $line
}

$info | Format-Table -Wrap -AutoSize
```
