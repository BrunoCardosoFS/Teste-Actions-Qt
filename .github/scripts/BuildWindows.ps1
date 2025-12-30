# .github/scripts/BuildWindows.ps1
param (
    [string]$BuildDir = "build",
    [string]$Config = "Release",
    [string]$ProjectName = "Programa",
    [string]$Version = "v0.0.1"
)

Write-Host "--- Processando Versão ---"
Write-Host "Entrada bruta: $Version"
$RegexPattern = "\d+\.\d+\.\d+"
$Match = [regex]::Match($Version, $RegexPattern)
if ($Match.Success) {
    $CleanVersion = $Match.Value
} else {
    Write-Warning "Padrão de versão não encontrado em '$Version'. Usando fallback '1.0.0'."
    $CleanVersion = "1.0.0"
}
Write-Host "Versão limpa: $CleanVersion"

Write-Host "--- Iniciando Configuração CMake ---"
cmake -B $BuildDir -S . -DCMAKE_BUILD_TYPE=$Config -DAPP_VERSION="$Version" -DCLEAN_APP_VERSION="$CleanVersion"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "--- Compilando ---"
cmake --build $BuildDir --config $Config
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "--- Preparando Deploy (Windeployqt) ---"

$DistDir = "dist"
$AbsDistDir = Resolve-Path -Path $DistDir
if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
New-Item -ItemType Directory -Path $DistDir


Copy-Item "$BuildDir/$Config/$ProjectName.exe" -Destination $AbsDistDir

Write-Host "--- Rodando Windeployqt ---"
windeployqt --dir $AbsDistDir --no-translations "$AbsDistDir/$ProjectName.exe"

Write-Host "--- Criando Arquivo ZIP ---"
$ZipName = "${AbsDistDir}/../${ProjectName}-${Version}-Portable-Windows-x86_64.zip"
Compress-Archive -Path "$AbsDistDir/*" -DestinationPath $ZipName -Force

Write-Host "Build e Empacotamento concluídos: $ZipName"

Write-Host "--- Compilando Instalador NSIS ---"

$NsisScriptPath = Join-Path $PSScriptRoot "nsis\installer.nsi"

if (-not (Test-Path $NsisScriptPath)) {
    Write-Error "O arquivo installer.nsi não foi encontrado em: $NsisScriptPath"
    exit 1
}

Write-Host " "
Write-Host "-- Absolute Dist Path $AbsDistDir "
Write-Host "-- Version $Version"
Write-Host "-- Clean Version $CleanVersion"
Write-Host "-- NSIS Script Path: $NsisScriptPath"
Write-Host " "

makensis /DBUILD_DIR="$AbsDistDir" /DVERSION="$Version" /DCLEAN_VERSION="$CleanVersion" /V4 "$NsisScriptPath"

if ($LASTEXITCODE -ne 0) { 
    Write-Error "Falha ao criar o instalador NSIS"
    exit $LASTEXITCODE 
}

Write-Host "--- Instalador Criado com Sucesso ---"

