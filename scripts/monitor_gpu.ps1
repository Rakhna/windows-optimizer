<#
.SYNOPSIS
    Monitor de rendimiento y temperatura en tiempo real para NVIDIA GeForce RTX 4050.
.DESCRIPTION
    Monitorea cada segundo: Temperatura, Reloj del nucleo, Reloj de memoria,
    Consumo en Watts y VRAM en uso. Al presionar Ctrl+C muestra un resumen con los picos maximos.
#>

Write-Output "======================================================"
Write-Output "   MONITOR DE TEMPERATURA Y RENDIMIENTO GPU (RTX 4050)"
Write-Output "======================================================"
Write-Output "Presiona Ctrl+C para detener el monitoreo y ver el resumen.`n"

$maxTemp = 0
$maxWatts = 0
$maxVram = 0
$samples = 0

try {
    while ($true) {
        $data = nvidia-smi --query-gpu=temperature.gpu,power.draw,clocks.gr,clocks.mem,memory.used,memory.total --format=csv,noheader,nounits
        $parts = $data.Split(',')
        $temp = [int]$parts[0].Trim()
        $watts = [double]$parts[1].Trim()
        $clockCore = $parts[2].Trim()
        $clockMem = $parts[3].Trim()
        $vramUsed = [int]$parts[4].Trim()
        $vramTotal = [int]$parts[5].Trim()

        if ($temp -gt $maxTemp) { $maxTemp = $temp }
        if ($watts -gt $maxWatts) { $maxWatts = $watts }
        if ($vramUsed -gt $maxVram) { $maxVram = $vramUsed }
        $samples++

        $thermalStatus = if ($temp -ge 85) { "[ALERTA: THERMAL THROTTLING]" } elseif ($temp -ge 75) { "[MODERADO]" } else { "[OPTIMO]" }

        $line = ("[{0}] Temp: {1,2} C {2,-10} | Consumo: {3,5:N1} W | Reloj: {4,4} MHz | VRAM: {5,4} / {6} MB" -f (Get-Date -Format "HH:mm:ss"), $temp, $thermalStatus, $watts, $clockCore, $vramUsed, $vramTotal)
        Write-Host $line
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Output "`n======================================================"
    Write-Output "                    RESUMEN DE SESION                 "
    Write-Output "======================================================"
    Write-Output ("Muestras tomadas: {0}" -f $samples)
    Write-Output ("Temperatura maxima: {0} C" -f $maxTemp)
    Write-Output ("Consumo maximo: {0:N1} W" -f $maxWatts)
    Write-Output ("VRAM maxima utilizada: {0} MB" -f $maxVram)
    if ($maxTemp -ge 86) {
        Write-Output "[WARNING] Se superaron los 85 C. Considera elevar la base de la laptop para mejorar el flujo de aire."
    } else {
        Write-Output "[OK] Temperaturas dentro del rango termico seguro."
    }
    Write-Output "======================================================"
}
