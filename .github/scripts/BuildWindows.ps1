# .github/scripts/BuildWindows.ps1
param (
    [string]$BuildDir = "build",
    [string]$Config = "Release",
    [string]$ProjectName = "MeuApp" # Mude para o nome do seu executável
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
windeployqt --dir $DistDir --no-translations --no-compiler-runtime "$DistDir/$ProjectName.exe"

Write-Host "--- Criando Arquivo ZIP ---"
$ZipName = "${ProjectName}-Windows-x86_64.zip"
Compress-Archive -Path "$DistDir/*" -DestinationPath $ZipName -Force

Write-Host "Build e Empacotamento concluídos: $ZipName"