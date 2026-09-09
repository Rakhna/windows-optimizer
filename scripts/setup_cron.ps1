$taskName = "AutoCleanRAM"
$scriptPath = "$PSScriptRoot\clean_ram.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 30)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable

$task = Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force -ErrorAction Stop

Write-Host ("======================================================") -ForegroundColor Cyan
Write-Host ("      CRON DE OPTIMIZACION DE MEMORIA RAM ACTIVO      ") -ForegroundColor Cyan
Write-Host ("======================================================") -ForegroundColor Cyan
Write-Host ("Tarea programada:  {0}" -f $taskName) -ForegroundColor White
Write-Host ("Intervalo:         Cada 30 minutos") -ForegroundColor Yellow
Write-Host ("Modo de ejecucion: 100% Silencioso en segundo plano") -ForegroundColor Green
Write-Host ("Estado:            {0}" -f $task.State) -ForegroundColor White
Write-Host ("======================================================") -ForegroundColor Cyan
