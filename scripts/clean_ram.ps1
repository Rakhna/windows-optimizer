$before = [math]::Round(((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024), 0)

$code = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class RamTrimmer {
    [DllImport("psapi.dll")]
    public static extern int EmptyWorkingSet(IntPtr hwProc);

    public static int TrimAll() {
        int count = 0;
        Process[] procs = Process.GetProcesses();
        foreach (Process p in procs) {
            try {
                if (EmptyWorkingSet(p.Handle) != 0) {
                    count++;
                }
            } catch {}
        }
        return count;
    }
}
"@
Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
$procs = [RamTrimmer]::TrimAll()

$after = [math]::Round(((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024), 0)
$freed = $after - $before

Write-Host ("======================================================") -ForegroundColor Cyan
Write-Host ("           LIBERADOR DE MEMORIA RAM EN VIVO           ") -ForegroundColor Cyan
Write-Host ("======================================================") -ForegroundColor Cyan
Write-Host ("Procesos compactados:   {0}" -f $procs) -ForegroundColor White
Write-Host ("RAM libre antes:        {0,5} MB" -f $before) -ForegroundColor Gray
Write-Host ("RAM libre actual:       {0,5} MB" -f $after) -ForegroundColor Green
if ($freed -gt 0) {
    Write-Host ("Memoria neta liberada: +{0,5} MB" -f $freed) -ForegroundColor Yellow
} else {
    Write-Host ("La memoria ya se encontraba en su maxima compactacion.") -ForegroundColor Gray
}
Write-Host ("======================================================") -ForegroundColor Cyan
