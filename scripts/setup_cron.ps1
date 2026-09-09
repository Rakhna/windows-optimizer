# scripts/setup_cron.ps1
$taskName = "AutoCleanRAM"
$installDir = "C:\WindowsOptimizer"
$silentPs1 = Join-Path $PSScriptRoot "clean_ram_silent.ps1"
$silentVbs = Join-Path $PSScriptRoot "clean_ram_silent.vbs"
$targetPs1 = Join-Path $installDir "clean_ram_silent.ps1"
$targetVbs = Join-Path $installDir "clean_ram_silent.vbs"

# Asegurar directorio de instalacion permanente en C:\
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
}

# Desplegar scripts a C:\WindowsOptimizer
Copy-Item -Path $silentPs1 -Destination $targetPs1 -Force
Copy-Item -Path $silentVbs -Destination $targetVbs -Force

$repoRoot = (Get-Item $PSScriptRoot).Parent.FullName
$repoCleanBat = Join-Path $repoRoot "clean_ram.bat"
$repoDisableBat = Join-Path $repoRoot "disable_ram_cron.bat"

if (Test-Path $repoCleanBat) {
    Copy-Item -Path $repoCleanBat -Destination (Join-Path $installDir "clean_ram.bat") -Force
}

if (Test-Path $repoDisableBat) {
    Copy-Item -Path $repoDisableBat -Destination (Join-Path $installDir "disable_ram_cron.bat") -Force
}

# Accion de la tarea programada: wscript.exe ejecutando VBS en modo SW_HIDE (0)
# Esto garantiza CERO destellos de consola (0 pixeles en pantalla, imposible robar foco a DirectX)
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$targetVbs`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 30)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -Priority 7

# Eliminar tarea previa si existia para refrescar la definicion
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

$task = Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force -ErrorAction Stop

Write-Host ("======================================================") -ForegroundColor Cyan
Write-Host ("   CRON 100% INVISIBLE DE MEMORIA RAM CONFIGURADO     ") -ForegroundColor Cyan
Write-Host ("======================================================") -ForegroundColor Cyan
Write-Host ("Tarea programada:  {0}" -f $taskName) -ForegroundColor White
Write-Host ("Lanzador nativo:   wscript.exe (SW_HIDE 0)") -ForegroundColor Green
Write-Host ("Motor inteligente: {0}" -f $targetPs1) -ForegroundColor Green
Write-Host ("Proteccion juegos: Activa (Excluye ventana activa y GPU > 35%)") -ForegroundColor Yellow
Write-Host ("Intervalo:         Cada 30 minutos") -ForegroundColor White
Write-Host ("Estado:            {0}" -f $task.State) -ForegroundColor Green
Write-Host ("======================================================") -ForegroundColor Cyan