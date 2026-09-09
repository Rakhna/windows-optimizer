# tests/Syntax.Tests.ps1
Write-Host "Running Syntax Verification Tests..." -ForegroundColor Cyan
$repoRoot = (Get-Item $PSScriptRoot).Parent.FullName
$scripts = Get-ChildItem -Path $repoRoot -Recurse -Filter "*.ps1" | Where-Object { $_.FullName -notmatch '\\\.git\\' }

$failed = 0
foreach ($file in $scripts) {
    $errors = $null
    $tokens = $null
    [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count -gt 0) {
        Write-Host ("  [FAIL] {0}" -f $file.Name) -ForegroundColor Red
        $errors | ForEach-Object { Write-Host ("    Error: {0}" -f $_.Message) -ForegroundColor Red }
        $failed++
    } else {
        Write-Host ("  [PASS] {0}" -f $file.Name) -ForegroundColor Green
    }
}

if ($failed -gt 0) {
    Write-Host ("`nTotal failed scripts: {0}" -f $failed) -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nAll PowerShell scripts passed syntax validation!" -ForegroundColor Green
    exit 0
}