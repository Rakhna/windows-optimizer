@echo off
title Desactivar Cron de Memoria RAM
schtasks /Delete /TN "AutoCleanRAM" /F >nul 2>&1
echo [OK] Tarea programada AutoCleanRAM eliminada de Windows.
if exist "C:\WindowsOptimizer" (
    rmdir /s /q "C:\WindowsOptimizer" >nul 2>&1
    echo [OK] Archivos temporales de C:\WindowsOptimizer retirados.
)
pause

