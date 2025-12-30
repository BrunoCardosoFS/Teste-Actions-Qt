# .github/scripts/BuildWindows.ps1
param (
    [string]$BuildDir = "build",
    [string]$Config = "Release",
    [string]$ProjectName = "Programa",
    [string]$Version = "v1.0.0"
)


Write-Host "--- Processing Version ---"
$RegexPattern = "\d+\.\d+\.\d+"
$Match = [regex]::Match($Version, $RegexPattern)
if ($Match.Success) {
    $CleanVersion = $Match.Value
} else {
    $CleanVersion = "1.0.0"
}


Write-Host "--- Starting CMake Configuration ---"
cmake -B $BuildDir -S . -DCMAKE_BUILD_TYPE=$Config -DAPP_VERSION="$Version" -DCLEAN_APP_VERSION="$CleanVersion"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }


Write-Host "--- Compiling ---"
cmake --build $BuildDir --config $Config
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }


Write-Host "--- Preparing Deploy ---"
$DistDir = "dist"
if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
New-Item -ItemType Directory -Path $DistDir
Copy-Item "$BuildDir/$Config/$ProjectName.exe" -Destination $AbsDistDir
$AbsDistDir = Resolve-Path -Path $DistDir


Write-Host "--- Windeployqt ---"
windeployqt --dir $AbsDistDir --no-translations "$AbsDistDir/$ProjectName.exe"


Write-Host "--- Creating a ZIP File ---"
$ZipName = "${AbsDistDir}/../${ProjectName}-${Version}-Portable-Windows-x86_64.zip"
Compress-Archive -Path "$AbsDistDir/*" -DestinationPath $ZipName -Force
Write-Host "Build and Packaging completed: $ZipName"


Write-Host "--- Downloading Visual C++ Redistributable ---"
$VcRedistUrl = "https://aka.ms/vc14/vc_redist.x64.exe"
$VcRedistPath = Join-Path $AbsDistDir "/../vc_redist.x64.exe"
Try {
    Invoke-WebRequest -Uri $VcRedistUrl -OutFile $VcRedistPath -UseBasicParsing
    Write-Host "VC Redist downloaded on: $VcRedistPath"
}
Catch {
    Write-Error "Error downloading VC Redist: $_"
    exit 1
}


Write-Host "--- Compiling NSIS Installer ---"
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