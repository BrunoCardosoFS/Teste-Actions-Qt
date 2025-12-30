# .github/scripts/BuildWindows.ps1
param (
    [string]$BuildDir = "build",
    [string]$Config = "Release",
    [string]$ProjectName = "Programa",
    [string]$Version = "0.0.0"
)

Write-Host "--- Iniciando Configuração CMake ---"
cmake -B $BuildDir -S . -DCMAKE_BUILD_TYPE=$Config
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "--- Compilando ---"
cmake --build $BuildDir --config $Config
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "--- Preparando Deploy (Windeployqt) ---"

$DistDir = "dist"
if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
New-Item -ItemType Directory -Path $DistDir


Copy-Item "$BuildDir/$Config/$ProjectName.exe" -Destination $DistDir

Write-Host "--- Rodando Windeployqt ---"
windeployqt --dir $DistDir --no-translations "$DistDir/$ProjectName.exe"

Write-Host "--- Criando Arquivo ZIP ---"
$ZipName = "${ProjectName}-v${Version}-Portable-Windows-x86_64.zip"
Compress-Archive -Path "$DistDir/*" -DestinationPath $ZipName -Force

Write-Host "Build e Empacotamento concluídos: $ZipName"

Write-Host "--- Compilando Instalador NSIS ---"
if (-not (Test-Path "nsis/installer.nsi")) {
    Write-Error "O arquivo installer.nsi não foi encontrado na raiz!"
    exit 1
}

makensis /DBUILD_DIR="$DistDir" /DVERSION="$Version" /V4 nsis/installer.nsi

if ($LASTEXITCODE -ne 0) { 
    Write-Error "Falha ao criar o instalador NSIS"
    exit $LASTEXITCODE 
}

Write-Host "--- Instalador Criado com Sucesso ---"