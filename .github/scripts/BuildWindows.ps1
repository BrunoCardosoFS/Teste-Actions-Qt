# .github/scripts/BuildWindows.ps1
param (
    [string]$BuildDir = "build",
    [string]$Config = "Release",
    [string]$ProjectName = "Programa",
    [string]$Version = "v1.0.0"
)


Write-Host "--- Processing Version ---" -ForegroundColor Green
$RegexPattern = "\d+\.\d+\.\d+"
$Match = [regex]::Match($Version, $RegexPattern)
if ($Match.Success) {
    $CleanVersion = $Match.Value
} else {
    $CleanVersion = "1.0.0"
}


Write-Host "--- Starting CMake Configuration ---" -ForegroundColor Green
cmake -B $BuildDir -S . -DCMAKE_BUILD_TYPE=$Config -DAPP_VERSION="$Version" -DCLEAN_APP_VERSION="$CleanVersion"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }


Write-Host "--- Compiling ---" -ForegroundColor Green
cmake --build $BuildDir --config $Config
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }


Write-Host "--- Preparing Deploy ---" -ForegroundColor Green
$DistDir = "dist"

if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
New-Item -ItemType Directory -Path $DistDir
New-Item -ItemType Directory -Path "$DistDir\$ProjectName"

$AbsDistDir = Resolve-Path -Path $DistDir
Copy-Item "$BuildDir\$Config\$ProjectName.exe" -Destination "$AbsDistDir\$ProjectName"

Write-Host "--- Windeployqt ---" -ForegroundColor Green
windeployqt --dir $AbsDistDir\$ProjectName --no-translations "$AbsDistDir\$ProjectName\$ProjectName.exe"


Write-Host "--- Get NaxiServer ---" -ForegroundColor Green
$Repo = "BrunoCardosoFS/NaxiServer"
$FileName = "NaxiServer-Windows-x86_64.zip"
$ApiUrl = "https://api.github.com/repos/$Repo/releases"

try {
    $Releases = Invoke-RestMethod -Uri $ApiUrl -Method Get
    $LatestPre = $Releases | Where-Object { $_.prerelease -eq $true } | Select-Object -First 1

    if ($null -eq $LatestPre) {
        Write-Host "No releases were found in this repository." -ForegroundColor Red
        exit
    }

    Write-Host "Found version: $($LatestPre.tag_name)"
    $Asset = $LatestPre.assets | Where-Object { $_.name -eq $FileName }

    if ($null -eq $Asset) {
        Write-Host "The file '$FileName' was not found in the version: $($LatestPre.tag_name)." -ForegroundColor Red
        Write-Host "Available files: $($LatestPre.assets.name -join ', ')"
        exit
    }

    $DownloadUrl = $Asset.browser_download_url
    $ZipPath = "$FileName"

    Write-Host "Downloading $FileName..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath

    Write-Host "Unpacking to $AbsDistDir..." -ForegroundColor Yellow
    Expand-Archive -Path $ZipPath -DestinationPath $AbsDistDir -Force

    Remove-Item $ZipPath

    Write-Host "Success! Files extracted from: $AbsDistDir"

} catch {
    Write-Host "An error occurred while accessing the API: $_" -ForegroundColor Red
}


Write-Host "--- Creating a ZIP File ---" -ForegroundColor Green
$ZipName = "${AbsDistDir}\..\${ProjectName}-${Version}-Portable-Windows-x86_64.zip"
Compress-Archive -Path "$AbsDistDir\*" -DestinationPath $ZipName -Force
Write-Host "Build and Packaging completed: $ZipName"


Write-Host "--- Downloading Visual C++ Redistributable ---" -ForegroundColor Green
$VcRedistUrl = "https://aka.ms/vc14/vc_redist.x64.exe"
$VcRedistPath = Join-Path $AbsDistDir "\..\vc_redist.x64.exe"
Try {
    Invoke-WebRequest -Uri $VcRedistUrl -OutFile $VcRedistPath -UseBasicParsing
    Write-Host "VC Redist downloaded on: $VcRedistPath"
}
Catch {
    Write-Error "Error downloading VC Redist: $_"
    exit 1
}


Write-Host "--- Compiling NSIS Installer ---" -ForegroundColor Green
$NsisScriptPath = Join-Path $PSScriptRoot "nsis\installer.nsi"
if (-not (Test-Path $NsisScriptPath)) {
    Write-Error "The installer.nsi file was not found in: $NsisScriptPath"
    exit 1
}
makensis /DBUILD_DIR="$AbsDistDir" /DVERSION="$Version" /DCLEAN_VERSION="$CleanVersion" /V4 "$NsisScriptPath"

if ($LASTEXITCODE -ne 0) { 
    Write-Error "Failed to create the NSIS installer."
    exit $LASTEXITCODE 
}