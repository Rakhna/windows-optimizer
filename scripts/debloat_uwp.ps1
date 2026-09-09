<#
.SYNOPSIS
    Desinstalador seguro de bloatware UWP para Windows 10 y Windows 11.
.DESCRIPTION
    Remueve aplicaciones y stubs no esenciales del usuario actual preservando
    estrictamente componentes del sistema, controladores de hardware, codecs
    y utilidades basicas (Calculadora, Fotos, Bloc de Notas, Tienda, Defender).
.PARAMETER DryRun
    Si se especifica, solo simula e imprime los paquetes que serian removidos.
#>
[CmdletBinding()]
param(
    [switch]$DryRun
)

$bloatList = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Office.ActionsServer",
    "Microsoft.OfficePushNotificationUtility",
    "Microsoft.M365Companions",
    "aimgr",
    "Microsoft.People",
    "Microsoft.Todos",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.Windows.DevHome",
    "Microsoft.YourPhone",
    "MicrosoftCorporationII.QuickAssist",
    "MicrosoftCorporationII.ShiftingHorizons",
    "Microsoft.549981C3F5F10"
)

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "       DESINSTALADOR SEGURO DE BLOATWARE UWP          " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

$installed = Get-AppxPackage | Where-Object { -not $_.IsFramework -and $_.NonRemovable -ne $true }
$foundCount = 0
$removedCount = 0

foreach ($target in $bloatList) {
    $matched = $installed | Where-Object { $_.Name -like "*$target*" }
    foreach ($pkg in $matched) {
        $foundCount++
        if ($DryRun) {
            Write-Host ("[SIMULACION] Se removeria: {0}" -f $pkg.Name) -ForegroundColor Yellow
        } else {
            Write-Host ("Removiendo: {0}..." -f $pkg.Name) -ForegroundColor Gray
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                Write-Host ("  [OK] Removido: {0}" -f $pkg.Name) -ForegroundColor Green
                $removedCount++
            } catch {
                Write-Host ("  [ERROR] No se pudo remover {0}: {1}" -f $pkg.Name, $_.Exception.Message) -ForegroundColor Red
            }
        }
    }
}

Write-Host "======================================================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host ("Simulacion completada. Paquetes candidatos encontrados: {0}" -f $foundCount) -ForegroundColor Yellow
} else {
    Write-Host ("Proceso completado. Paquetes desinstalados: {0} de {1} detectados." -f $removedCount, $foundCount) -ForegroundColor Green
}
Write-Host "======================================================" -ForegroundColor Cyan