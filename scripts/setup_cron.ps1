# scripts/setup_cron.ps1
$taskName = "AutoCleanRAM"
$installDir = "C:\WindowsOptimizer"
$targetScript = Join-Path $installDir "clean_ram.ps1"
$sourceScript = Join-Path $PSScriptRoot "clean_ram.ps1"

# Asegurar directorio de instalacion permanente en C:\
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
}

# Copiar script a C:\WindowsOptimizer para que la tarea sea inmune a cambios en la carpeta git
Copy-Item -Path $sourceScript -Destination $targetScript -Force

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
