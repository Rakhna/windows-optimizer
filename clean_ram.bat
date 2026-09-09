@echo off
title Compactador Instantaneo de Memoria RAM
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\clean_ram.ps1"
echo Presiona cualquier tecla para cerrar...
pause >nul
