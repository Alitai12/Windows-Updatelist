#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# -----------------------------
# Konfiguration
# -----------------------------
$DriverPath = 'C:\ChromeDriver\'   # Pfad zu ChromeDriver
$filePath   = 'C:\Temp\Windows 11 24H2 26100.txt'
$remotePath = 'Windows 11 24H2 26100.txt'
$commitMessage = "Windows 11 24H2 26100 Updatelist $(Get-Date -Format yyyy-MM-dd_HH-mm)"
$branch = 'main'
$owner = 'Alitai12'
$repo  = 'Windows-Updatelist'
$token = ''   # Hier dein GitHub PAT einfügen

# -----------------------------
# 1️⃣ Selenium: Webseite auslesen
# -----------------------------
$Driver = Start-SeChrome -WebDriverDirectory $DriverPath -Headless
$Driver.Navigate().GoToUrl("https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information")
Start-Sleep -Seconds 5
# Warten, bis der Button sichtbar ist
Start-Sleep -Seconds 3

# Das <details>-Element suchen, das 'Windows Server 2022' enthält
$ws2022Details = $Driver.FindElementByXPath("//details[summary[contains(., 'Version 24H2 (OS build 26100)')]]")

# prüfen, ob es bereits geöffnet ist
$opened = $ws2022Details.GetAttribute("open")
if (-not $opened) {
    # <summary> anklicken, um das Akkordeon zu öffnen
    $summary = $ws2022Details.FindElementByTagName("summary")
    $summary.Click()
    Start-Sleep -Seconds 2
}

$ws2022Content = $ws2022Details.Text
$ws2022Lines = $ws2022Content -split "`n"
$Driver.Quit()

# -----------------------------
# 2️⃣ Zeilen filtern
# -----------------------------
$lines = $ws2022Lines -split "`n"
$gaLines = $lines | Where-Object { $_ -like "LTSC*" }

# -----------------------------
# 3️⃣ TXT-Datei speichern
# -----------------------------
$gaLines | Out-File $filePath -Encoding UTF8

# -----------------------------
# 4️⃣ GitHub API: Datei hochladen / überschreiben
# -----------------------------
# Base64-kodierter Inhalt
$content = [Convert]::ToBase64String([IO.File]::ReadAllBytes($filePath))

# Prüfen, ob Datei existiert (SHA abrufen)
$existingSha = $null
try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/contents/$remotePath" `
                                  -Headers @{
                                      Authorization = "Bearer $token"
                                      Accept        = "application/vnd.github+json"
                                      "X-GitHub-Api-Version" = "2022-11-28"
                                  } `
                                  -Method Get
    if ($response -and $response.sha) {
        $existingSha = $response.sha
        Write-Host "Datei existiert. SHA von GitHub: $existingSha"
    }
} catch {
    Write-Host "Datei existiert nicht – wird neu erstellt."
}

# JSON Body vorbereiten (kein -Compress!)
$body = @{
    message   = $commitMessage
    committer = @{
        name  = "UpdaterBot"
        email = "updater@local"
    }
    content   = $content
    branch    = $branch
}
if ($existingSha) {
    $body.sha = $existingSha   # SHA nur einfügen, wenn Datei existiert
}

$bodyJson = ConvertTo-Json $body -Depth 4

# -----------------------------
# 4️⃣1 Testausgabe: JSON Body anzeigen
# -----------------------------
Write-Host "---------------------------"
Write-Host "JSON-Body für GitHub Upload:"
Write-Host $bodyJson
Write-Host "---------------------------"

# Datei hochladen / aktualisieren
$responseUpload = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/contents/$remotePath" `
                                    -Headers @{
                                        Authorization = "Bearer $token"
                                        Accept        = "application/vnd.github+json"
                                        "X-GitHub-Api-Version" = "2022-11-28"
                                    } `
                                    -Method Put `
                                    -Body $bodyJson

Write-Host "✅ TXT-Datei erfolgreich auf GitHub hochgeladen / aktualisiert."
Write-Host "➡️  Neuer SHA laut GitHub: $($responseUpload.content.sha)"
