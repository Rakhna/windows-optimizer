# scripts/clean_ram_silent.ps1
# Smart & Silent Background RAM Trimmer for Windows 11
# Excludes active foreground window, gaming processes, and skips if active 3D load is detected.

$logFile = "C:\WindowsOptimizer\ram_cleaner.log"

function Write-SilentLog ($msg) {
    try {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $entry = "[$timestamp] $msg"
        Add-Content -Path $logFile -Value $entry -ErrorAction SilentlyContinue
        if (Test-Path $logFile) {
            $lines = Get-Content $logFile -ErrorAction SilentlyContinue
            if ($lines.Count -gt 100) {
                $lines | Select-Object -Last 100 | Set-Content $logFile -ErrorAction SilentlyContinue
            }
        }
    } catch {}
}

# 1. Check if GPU is in active gaming load (> 35% 3D utilization)
try {
    $gpuUtilStr = (nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>$null).Trim()
    if ($gpuUtilStr -match '^\d+$') {
        $gpuUtil = [int]$gpuUtilStr
        if ($gpuUtil -gt 35) {
            Write-SilentLog "[SKIP] GPU load active ($gpuUtil%). Game in progress. Trim aborted."
            exit 0
        }
    }
} catch {}

$before = [math]::Round(((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024), 0)

$code = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class SmartRamTrimmer {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("psapi.dll")]
    public static extern int EmptyWorkingSet(IntPtr hwProc);

    public static uint GetForegroundPid() {
        IntPtr hWnd = GetForegroundWindow();
        uint pid = 0;
        GetWindowThreadProcessId(hWnd, out pid);
        return pid;
    }

    public static int TrimBackground() {
        uint fgPid = GetForegroundPid();
        int count = 0;
        string[] excluded = new string[] {
            "dwm", "csrss", "lsass", "services", "smss", "explorer",
            "warhammer", "spacemarine", "steam", "wallpaper64", "wallpaperui",
            "epicgameslauncher", "riotclientservices", "antigravity",
            "cyberpunk", "rdr2", "fortnite", "valorant", "overwatch"
        };
        Process[] procs = Process.GetProcesses();
        foreach (Process p in procs) {
            try {
                if (p.Id == fgPid || p.Id == 0 || p.Id == 4) continue;
                if (p.WorkingSet64 > 1500L * 1024L * 1024L) continue;

                string name = p.ProcessName.ToLowerInvariant();
                bool skip = false;
                foreach (string exc in excluded) {
                    if (name.Contains(exc)) { skip = true; break; }
                }
                if (skip) continue;

                if (EmptyWorkingSet(p.Handle) != 0) {
                    count++;
                }
            } catch {}
        }
        return count;
    }
}
"@

try {
    Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
    $trimmed = [SmartRamTrimmer]::TrimBackground()
    $after = [math]::Round(((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024), 0)
    $freed = $after - $before
    Write-SilentLog "[OK] Cleaned $trimmed background processes. RAM: ${before}MB -> ${after}MB (Freed: +${freed}MB)"
} catch {
    Write-SilentLog "[ERROR] $($_.Exception.Message)"
}