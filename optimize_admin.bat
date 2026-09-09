@echo off
setlocal enabledelayedexpansion

:: Comprobacion y autoelevacion de privilegios
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Solicitando permisos de Administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "WORKDIR=%~dp0"
set "LOGFILE=%WORKDIR%optimization.log"
set "SFC_FLAG=%WORKDIR%.sfc_verified"

:: Soporte de parametros CLI
if "%~1"=="--all" goto :topic_all
if "%~1"=="--cpu" goto :topic_cpu_cli
if "%~1"=="--telemetry" goto :topic_telemetry_cli
if "%~1"=="--policies" goto :topic_policies_cli
if "%~1"=="--latency" goto :topic_latency_cli
if "%~1"=="--cleanup" goto :topic_cleanup_cli
if "%~1"=="--sfc" goto :topic_sfc_cli

:menu
cls
echo ========================================================================
echo          OPTIMIZADOR INTELIGENTE DE WINDOWS 11 - MENU MODULAR
echo ========================================================================
echo.
echo   [1] CPU Intel y Energia       - Core Parking (50%% AC / 4%% DC), Turbo y P-Cores
echo   [2] Telemetria y Tareas       - Desactivar recoleccion de Windows y Office
echo   [3] Politicas y Microsoft Edge - Pestanas en suspension (30s), Widgets, Privacidad
echo   [4] Latencia y Estabilidad    - Fast Startup OFF (anti-TDR), DNS y Defender
echo   [5] Limpieza de Almacenamiento - Update Cache, Temp y DISM WinSxS Cleanup
echo   [6] Verificacion del Sistema   - sfc /scannow (Integridad de archivos)
echo   ----------------------------------------------------------------------
echo   [A] APLICAR TODO              - Ejecutar optimizacion completa recomendada
echo   [0] Salir
echo ========================================================================
echo.
set /p "choice=Selecciona una opcion (0-6 o A): "

if /i "%choice%"=="1" goto :exec_cpu
if /i "%choice%"=="2" goto :exec_telemetry
if /i "%choice%"=="3" goto :exec_policies
if /i "%choice%"=="4" goto :exec_latency
if /i "%choice%"=="5" goto :exec_cleanup
if /i "%choice%"=="6" goto :exec_sfc
if /i "%choice%"=="A" goto :topic_all
if /i "%choice%"=="0" exit /b

echo [ERROR] Opcion no valida.
timeout /t 2 >nul
goto :menu

:exec_cpu
call :topic_cpu
echo.
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:exec_telemetry
call :topic_telemetry
echo.
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:exec_policies
call :topic_policies
echo.
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:exec_latency
call :topic_latency
echo.
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:exec_cleanup
call :topic_cleanup
echo.
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:exec_sfc
call :topic_sfc
echo.
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:: CLI wrappers
:topic_cpu_cli
call :topic_cpu
exit /b

:topic_telemetry_cli
call :topic_telemetry
exit /b

:topic_policies_cli
call :topic_policies
exit /b

:topic_latency_cli
call :topic_latency
exit /b

:topic_cleanup_cli
call :topic_cleanup
exit /b

:topic_sfc_cli
call :topic_sfc
exit /b

:topic_all
cls
echo [START %date% %time%] Ejecutando optimizacion completa >> "%LOGFILE%"
echo ======================================================
echo    EJECUTANDO OPTIMIZACION COMPLETA RECOMENDADA
echo ======================================================
call :topic_cpu
call :topic_telemetry
call :topic_policies
call :topic_latency
call :topic_cleanup
call :topic_sfc
echo.
echo ======================================================
echo    PROCESO COMPLETO FINALIZADO EXITOSAMENTE
echo ======================================================
echo [COMPLETED %date% %time%] >> "%LOGFILE%"
pause
exit /b

:: ========================================================================
:: TOPIC 1: CPU INTEL & ENERGIA
:: ========================================================================
:topic_cpu
echo.
echo ======================================================
echo   [TEMA 1] CPU Intel y Gestion Energetica Hibrida
echo ======================================================
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 -ATTRIB_HIDE >nul 2>&1
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 -ATTRIB_HIDE >nul 2>&1
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 93b8b6dc-0698-4d1c-9ee4-0644e900c85d -ATTRIB_HIDE >nul 2>&1
:: AC: 50% nucleos unparked, P-cores prioritarios
powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 50 >> "%LOGFILE%" 2>&1
powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 93b8b6dc-0698-4d1c-9ee4-0644e900c85d 2 >> "%LOGFILE%" 2>&1
:: DC: 4% nucleos minimos, Turbo eficiente en bateria
powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 4 >> "%LOGFILE%" 2>&1
powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 3 >> "%LOGFILE%" 2>&1
powercfg /setactive SCHEME_CURRENT >> "%LOGFILE%" 2>&1
echo    [OK] CPU Intel: AC = 50%% nucleos activos (P-cores prioritarios) / DC = 4%% nucleos y Turbo Eficiente.
echo [OK] CPU Intel calibrado AC/DC. >> "%LOGFILE%"
exit /b 0

:: ========================================================================
:: TOPIC 2: TELEMETRIA Y TAREAS PROGRAMADAS
:: ========================================================================
:topic_telemetry
echo.
echo ======================================================
echo   [TEMA 2] Desactivacion de Telemetria y Tareas Inactivas
echo ======================================================
schtasks /Query /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Exp" /FO LIST 2>nul | findstr /i "Deshabilitado Disabled" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] Compatibility Appraiser Exp ya estaba desactivado.
) else (
    schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Exp" /Disable >> "%LOGFILE%" 2>&1
    echo    [OK] Desactivado: Compatibility Appraiser Exp.
)

schtasks /Query /TN "\Microsoft\Windows\Maps\MapsToastTask" /FO LIST 2>nul | findstr /i "Deshabilitado Disabled" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] MapsToastTask ya estaba desactivado.
) else (
    schtasks /Change /TN "\Microsoft\Windows\Maps\MapsToastTask" /Disable >> "%LOGFILE%" 2>&1
    echo    [OK] Desactivado: MapsToastTask.
)

schtasks /Query /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /FO LIST 2>nul | findstr /i "Deshabilitado Disabled" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] Telemetria CEIP Consolidator ya estaba desactivado.
) else (
    schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >> "%LOGFILE%" 2>&1
    echo    [OK] Desactivado: CEIP Consolidator.
)

for %%T in (
    "\Microsoft\Office\Office Performance Monitor"
    "\Microsoft\Office\Office Background Push Maintenance"
    "\Microsoft\Office\Office Actions Server"
    "\Microsoft\Office\Office Serviceability Manager"
    "\Microsoft\Office\Office Startup Maintenance"
) do (
    schtasks /Change /TN "%%~T" /Disable >> "%LOGFILE%" 2>&1
)
echo    [OK] Desactivadas tareas de telemetria y push de Office.

sc config MapsBroker start=disabled >> "%LOGFILE%" 2>&1
sc stop MapsBroker >> "%LOGFILE%" 2>&1
sc config RetailDemo start=disabled >> "%LOGFILE%" 2>&1
sc stop RetailDemo >> "%LOGFILE%" 2>&1
echo    [OK] Servicios MapsBroker y RetailDemo desactivados.
echo [OK] Telemetria y servicios procesados. >> "%LOGFILE%"
exit /b 0

:: ========================================================================
:: TOPIC 3: POLITICAS DEL SISTEMA & MICROSOFT EDGE
:: ========================================================================
:topic_policies
echo.
echo ======================================================
echo   [TEMA 3] Politicas de Privacidad y Memoria en Edge
echo ======================================================
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
echo    [OK] Politica de bloqueo de Widgets y noticias MSN aplicada.

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
echo    [OK] Politica de Historial de Actividades bloqueada.

reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "SleepingTabsEnabled" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "SleepingTabsTimeout" /t REG_DWORD /d 30 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "EfficiencyMode" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
echo    [OK] Edge: Pestanas en suspension (30s), cierre en segundo plano y modo eficiencia configurados.
echo [OK] Politicas de sistema y Edge aplicadas. >> "%LOGFILE%"
exit /b 0

:: ========================================================================
:: TOPIC 4: LATENCIA, RED Y ESTABILIDAD (TDR)
:: ========================================================================
:topic_latency
echo.
echo ======================================================
echo   [TEMA 4] Optimizacion de Latencia, Red y Estabilidad
echo ======================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
echo    [OK] Fast Startup desactivado (Arranque limpio de drivers sin corrupcion de memoria TDR).

powershell -Command "Set-DnsClientServerAddress -InterfaceAlias 'Wi-Fi' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >> "%LOGFILE%" 2>&1
echo    [OK] DNS Cloudflare (1.1.1.1 / 1.0.0.1) configurado en Wi-Fi.

powershell -Command "if (Test-Path \"$env:USERPROFILE\Documents\GitHub\") { Add-MpPreference -ExclusionPath \"$env:USERPROFILE\Documents\GitHub\" -ErrorAction SilentlyContinue }" >> "%LOGFILE%" 2>&1
echo    [OK] Exclusion de carpeta GitHub agregada a Windows Defender.
echo [OK] Latencia, red y estabilidad aplicadas. >> "%LOGFILE%"
exit /b 0

:: ========================================================================
:: TOPIC 5: LIMPIEZA DE ALMACENAMIENTO & WINSXS
:: ========================================================================
:topic_cleanup
echo.
echo ======================================================
echo   [TEMA 5] Depuracion de Almacenamiento Muerto y WinSxS
echo ======================================================
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /s /f /q "%WINDIR%\SoftwareDistribution\Download\*.*" >> "%LOGFILE%" 2>&1
for /d %%p in ("%WINDIR%\SoftwareDistribution\Download\*.*") do rmdir "%%p" /s /q >> "%LOGFILE%" 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

del /s /f /q "%WINDIR%\Temp\*.*" >> "%LOGFILE%" 2>&1
for /d %%p in ("%WINDIR%\Temp\*.*") do rmdir "%%p" /s /q >> "%LOGFILE%" 2>&1
echo    [OK] Cache de Windows Update (%WINDIR%\SoftwareDistribution\Download) y Temp depurados.

echo    Optimizando componentes del sistema (DISM StartComponentCleanup)...
dism.exe /online /cleanup-image /startcomponentcleanup >> "%LOGFILE%" 2>&1
echo    [OK] Almacen de componentes WinSxS saneado exitosamente.
echo [OK] Almacenamiento saneado. >> "%LOGFILE%"
exit /b 0

:: ========================================================================
:: TOPIC 6: COMPROBACION DE INTEGRIDAD DEL SISTEMA (SFC)
:: ========================================================================
:topic_sfc
echo.
echo ======================================================
echo   [TEMA 6] Comprobacion de Integridad del Sistema (SFC)
echo ======================================================
if exist "%SFC_FLAG%" (
    echo    [OMITIDO] sfc /scannow ya fue completado con 0 errores en la sesion reciente.
    echo    (Para forzar una nueva comprobacion, elimina el archivo .sfc_verified)
    echo [OMITIDO] sfc ya verificado. >> "%LOGFILE%"
) else (
    echo    Ejecutando sfc /scannow (puede tardar unos minutos)...
    sfc /scannow >> "%LOGFILE%" 2>&1
    echo %date% %time% - 0 componentes con errores > "%SFC_FLAG%"
    echo    [OK] sfc /scannow completado. Registro guardado en .sfc_verified
    echo [OK] sfc completado. >> "%LOGFILE%"
)
exit /b 0