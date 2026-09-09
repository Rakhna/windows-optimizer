# tests/RamTrimmer.Tests.ps1
Write-Host "Running RamTrimmer Engine Unit Tests..." -ForegroundColor Cyan

$code = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class TestRamTrimmer {
    [DllImport("psapi.dll")]
    public static extern int EmptyWorkingSet(IntPtr hwProc);

    public static bool TestTrimCurrentProcess() {
        IntPtr handle = Process.GetCurrentProcess().Handle;
        int result = EmptyWorkingSet(handle);
        return result != 0;
    }
}
"@

try {
    Add-Type -TypeDefinition $code -ErrorAction Stop
    $success = [TestRamTrimmer]::TestTrimCurrentProcess()
    if ($success) {
        Write-Host "  [PASS] EmptyWorkingSet Win32 API compiled and executed successfully." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "  [FAIL] EmptyWorkingSet call returned false/zero." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host ("  [FAIL] Error during compilation or execution: {0}" -f $_.Exception.Message) -ForegroundColor Red
    exit 1
}