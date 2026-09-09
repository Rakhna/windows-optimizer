@echo off
title Desactivar Cron de Memoria RAM
echo ======================================================
echo      DESACTIVADOR DE TAREA AUTOCLEANRAM (C:\)
echo ======================================================
schtasks /Delete /TN "AutoCleanRAM" /F >nul 2>&1
echo [OK] Tarea programada AutoCleanRAM eliminada de Windows.
echo [INFO] La memoria ya no se compactara automaticamente cada 30 minutos.
echo.
set /p opt="Deseas eliminar tambien los archivos de C:\WindowsOptimizer? (S/N): "
if /i "%opt%"=="S" (
    echo [OK] Eliminando C:\WindowsOptimizer...
    start "" cmd /c "timeout /t 1 /nobreak >nul & rmdir /s /q ""C:\WindowsOptimizer"""
    exit
)
echo [OK] Archivos conservados para ejecucion manual.
pause