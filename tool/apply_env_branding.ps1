param(
  [string]$EnvFile = "lib/env/municipality_env.json"
)

$ErrorActionPreference = "Stop"

Write-Host "Reading env from: $EnvFile"

if (!(Test-Path $EnvFile)) {
  throw "Env file not found: $EnvFile"
}

$envJson = Get-Content $EnvFile -Raw | ConvertFrom-Json



$appName = $envJson.APP_NAME
if ([string]::IsNullOrWhiteSpace($appName)) {
  $appName = "Municipality"
}


$appNameEscaped = [System.Security.SecurityElement]::Escape($appName)

$apiBaseUrl = "$($envJson.API_BASE_URL)".TrimEnd("/")
$logoPath = $envJson.BRANDING.logoPath

$brandingDir = "assets/branding"
New-Item -ItemType Directory -Force -Path $brandingDir | Out-Null

$logoFile = "$brandingDir/logo.png"

if (![string]::IsNullOrWhiteSpace($logoPath)) {
    if ($logoPath.StartsWith("http")) {
        $logoUrl = $logoPath
    } else {
        $logoUrl = "$apiBaseUrl$logoPath"
    }

    Write-Host "Logo URL: $logoUrl"

    Invoke-WebRequest -Uri $logoUrl -OutFile $logoFile

   Add-Type -AssemblyName System.Drawing

$original = [System.Drawing.Image]::FromFile((Resolve-Path $logoFile).Path)

$size = 1024
$canvas = New-Object System.Drawing.Bitmap $size, $size
$graphics = [System.Drawing.Graphics]::FromImage($canvas)

$graphics.Clear([System.Drawing.Color]::White)

# كل ما كبر الرقم، اللوغو بصغر وبيبعد عن الأطراف
$paddingPercent = 0.30
$targetSize = [int]($size * (1 - $paddingPercent))

$x = [int](($size - $targetSize) / 2)
$y = [int](($size - $targetSize) / 2)

$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$graphics.DrawImage($original, $x, $y, $targetSize, $targetSize)

$launcherPath = "$brandingDir/launcher.png"
$splashPath = "$brandingDir/splash.png"

$canvas.Save($launcherPath, [System.Drawing.Imaging.ImageFormat]::Png)
$canvas.Save($splashPath, [System.Drawing.Imaging.ImageFormat]::Png)

$graphics.Dispose()
$canvas.Dispose()
$original.Dispose()

Write-Host "Logo padded:"
Write-Host "Launcher: $launcherPath"
Write-Host "Splash: $splashPath"

    Write-Host "Logo downloaded to: $logoFile"
} else {
    Write-Host "No BRANDING.logoPath found"
}

$valuesDir = "android/app/src/main/res/values"
$stringsFile = Join-Path $valuesDir "strings.xml"

New-Item -ItemType Directory -Force -Path $valuesDir | Out-Null

$xml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$appNameEscaped</string>
</resources>
"@

[System.IO.File]::WriteAllText(
  (Resolve-Path $valuesDir).Path + "\strings.xml",
  $xml,
  [System.Text.UTF8Encoding]::new($false)
)

Write-Host "APP_NAME from env: $appName"
Write-Host "Updated file: $stringsFile"
Write-Host "---- strings.xml now ----"
Get-Content $stringsFile