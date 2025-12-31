# .github/scripts/BuildWindows.ps1
param (
    [string]$BuildDir = "build_windows",
    [string]$Config = "Release",
    [string]$ProjectName = "Programa"
)

Write-Host "--- Starting CMake Configuration ---" -ForegroundColor Green
cmake -B $BuildDir -S . -DCMAKE_BUILD_TYPE=$Config -DAPP_VERSION="$env:VERSION" -DCLEAN_APP_VERSION="$env:CLEAN_VERSION"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }


Write-Host "--- Compiling ---" -ForegroundColor Green
cmake --build $BuildDir --config $Config
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }


Write-Host "--- Preparing Deploy ---" -ForegroundColor Green
$DistDir = $env:DIST_WINDOWS_DIR
New-Item -ItemType Directory -Path "$DistDir\$ProjectName"
Copy-Item "$BuildDir\$Config\$ProjectName.exe" -Destination "$DistDir\$ProjectName"
Remove-Item -Recurse -Force $BuildDir


Write-Host "--- Windeployqt ---" -ForegroundColor Green
windeployqt --dir $DistDir\$ProjectName --no-translations "$DistDir\$ProjectName\$ProjectName.exe"


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

    Write-Host "Unpacking to $DistDir..." -ForegroundColor Yellow
    Expand-Archive -Path $ZipPath -DestinationPath $DistDir -Force

    Remove-Item $ZipPath

    Write-Host "Success! Files extracted from: $DistDir"

} catch {
    Write-Host "An error occurred while accessing the API: $_" -ForegroundColor Red
}

Write-Host "--- Creating a ZIP File ---" -ForegroundColor Green
$ZipName = "$env:DIST_FILES_DIR\${ProjectName}-${Version}-Portable-Windows-x86_64.zip"
Compress-Archive -Path "$DistDir\*" -DestinationPath $ZipName -Force
Write-Host "Build and Packaging completed: $ZipName"


Write-Host "--- Downloading Visual C++ Redistributable ---" -ForegroundColor Green
$VcRedistUrl = "https://aka.ms/vc14/vc_redist.x64.exe"
$VcRedistPath = Join-Path $DistDir "\..\vc_redist.x64.exe"
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
makensis /DBUILD_DIR="$DistDir" /DVERSION="$Version" /DCLEAN_VERSION="$CleanVersion" /DOUTDIR="$env:DIST_FILES_DIR" /V4 "$NsisScriptPath"

if ($LASTEXITCODE -ne 0) { 
    Write-Error "Failed to create the NSIS installer."
    exit $LASTEXITCODE 
}

Remove-Item $VcRedistPath