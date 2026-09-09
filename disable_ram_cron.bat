@echo off
title Desactivar Cron de Memoria RAM
schtasks /Delete /TN "AutoCleanRAM" /F >nul 2>&1
echo [OK] Tarea programada AutoCleanRAM eliminada.
pause
