# scripts/setup_cron.ps1
$taskName = "AutoCleanRAM"
$installDir = "C:\WindowsOptimizer"
$targetScript = Join-Path $installDir "clean_ram.ps1"
$sourceScript = Join-Path $PSScriptRoot "clean_ram.ps1"

# Asegurar directorio de instalacion permanente en C:\
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
}

# Copiar archivos a C:\WindowsOptimizer para que la tarea y el desinstalador sean independientes de git
Copy-Item -Path $sourceScript -Destination $targetScript -Force

$repoRoot = (Get-Item $PSScriptRoot).Parent.FullName
$repoCleanBat = Join-Path $repoRoot "clean_ram.bat"
$repoDisableBat = Join-Path $repoRoot "disable_ram_cron.bat"

if (Test-Path $repoCleanBat) {
    # Version para ejecucion directa dentro de C:\WindowsOptimizer
    $cBatContent = "@echo off`r`ntitle Compactador Instantaneo de Memoria RAM`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0clean_ram.ps1`"`r`necho Presiona cualquier tecla para cerrar...`r`npause >nul"
    [System.IO.File]::WriteAllText((Join-Path $installDir "clean_ram.bat"), $cBatContent, [System.Text.Encoding]::Default)
}

if (Test-Path $repoDisableBat) {
    Copy-Item -Path $repoDisableBat -Destination (Join-Path $installDir "disable_ram_cron.bat") -Force
}

# Accion de la tarea programada apuntando a C:\
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$targetScript`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 30)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable

$task = Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force -ErrorAction Stop

Write-Host ("======================================================") -ForegroundColor Cyan
Write-Host ("      CRON DE OPTIMIZACION DE MEMORIA RAM ACTIVO      ") -ForegroundColor Cyan
Write-Host ("======================================================") -ForegroundColor Cyan
Write-Host ("Tarea programada:  {0}" -f $taskName) -ForegroundColor White
Write-Host ("Ubicacion motor:   {0}" -f $targetScript) -ForegroundColor Green
Write-Host ("Intervalo:         Cada 30 minutos") -ForegroundColor Yellow
Write-Host ("Modo de ejecucion: 100% Silencioso en segundo plano") -ForegroundColor Green
Write-Host ("Estado:            {0}" -f $task.State) -ForegroundColor White
Write-Host ("======================================================") -ForegroundColor Cyan
