@echo off
title Activar Cron de Memoria RAM
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup_cron.ps1"
pause
