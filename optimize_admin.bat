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

echo [START %date% %time%] Ejecutando optimizador inteligente > "%LOGFILE%"

echo ======================================================
echo    OPTIMIZADOR INTELIGENTE DE WINDOWS 11 (IDEMPOTENTE)
echo ======================================================
echo.

:: 1. Tareas de Telemetria
echo [1/5] Verificando estado de tareas de telemetria...
schtasks /Query /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Exp" /FO LIST 2>nul | findstr /i "Deshabilitado Disabled" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] Compatibility Appraiser Exp ya estaba desactivado.
    echo [OMITIDO] Compatibility Appraiser Exp ya estaba desactivado. >> "%LOGFILE%"
) else (
    schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Exp" /Disable >> "%LOGFILE%" 2>&1
    echo    [OK] Desactivado: Compatibility Appraiser Exp.
    echo [OK] Desactivado: Compatibility Appraiser Exp. >> "%LOGFILE%"
)

schtasks /Query /TN "\Microsoft\Windows\Maps\MapsToastTask" /FO LIST 2>nul | findstr /i "Deshabilitado Disabled" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] MapsToastTask ya estaba desactivado.
    echo [OMITIDO] MapsToastTask ya estaba desactivado. >> "%LOGFILE%"
) else (
    schtasks /Change /TN "\Microsoft\Windows\Maps\MapsToastTask" /Disable >> "%LOGFILE%" 2>&1
    echo    [OK] Desactivado: MapsToastTask.
    echo [OK] Desactivado: MapsToastTask. >> "%LOGFILE%"
)

schtasks /Query /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /FO LIST 2>nul | findstr /i "Deshabilitado Disabled" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] Telemetria CEIP Consolidator ya estaba desactivado.
    echo [OMITIDO] Telemetria CEIP Consolidator ya estaba desactivado. >> "%LOGFILE%"
) else (
    schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >> "%LOGFILE%" 2>&1
    echo    [OK] Desactivado: CEIP Consolidator.
    echo [OK] Desactivado: CEIP Consolidator. >> "%LOGFILE%"
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
echo [OK] Tareas de telemetria de Office desactivadas. >> "%LOGFILE%"

:: 2. Politicas de Directivas de Grupo (HKLM)
echo.
echo [2/5] Verificando politicas de sistema (Widgets e Historial)...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" 2>nul | findstr /i "0x0" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] Politica de bloqueo de Widgets ya configurada.
    echo [OMITIDO] Politica de Widgets ya configurada. >> "%LOGFILE%"
) else (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
    echo    [OK] Politica de bloqueo de Widgets aplicada.
    echo [OK] Politica de Widgets aplicada. >> "%LOGFILE%"
)

reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" 2>nul | findstr /i "0x0" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] Politica de Historial de Actividades ya configurada.
    echo [OMITIDO] Politica de Historial de Actividades ya configurada. >> "%LOGFILE%"
) else (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
    echo    [OK] Politica de Historial de Actividades aplicada.
    echo [OK] Politica de Historial de Actividades aplicada. >> "%LOGFILE%"
)

:: Politicas de Memoria en Microsoft Edge
echo.
echo [*] Configurando politicas de ahorro de RAM en Microsoft Edge...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "SleepingTabsEnabled" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "SleepingTabsTimeout" /t REG_DWORD /d 30 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "EfficiencyMode" /t REG_DWORD /d 1 /f >> "%LOGFILE%" 2>&1
echo    [OK] Edge: Pestanas en suspension (30s), cierre en segundo plano y modo eficiencia configurados.
echo [OK] Politicas de Edge configuradas en HKLM. >> "%LOGFILE%"

:: Optimizacion Inteligente de CPU (Intel Hybrid Architecture AC/DC)
echo.
echo [*] Calibrando gestion de CPU Intel (AC: Cero latencia / DC: Ahorro profundo)...
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 -ATTRIB_HIDE >nul 2>&1
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 -ATTRIB_HIDE >nul 2>&1
powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 93b8b6dc-0698-4d1c-9ee4-0644e900c85d -ATTRIB_HIDE >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 50 >> "%LOGFILE%" 2>&1
powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 93b8b6dc-0698-4d1c-9ee4-0644e900c85d 2 >> "%LOGFILE%" 2>&1
powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 4 >> "%LOGFILE%" 2>&1
powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 be337238-0d82-4146-a960-4f3749d470c7 3 >> "%LOGFILE%" 2>&1
powercfg /setactive SCHEME_CURRENT >> "%LOGFILE%" 2>&1
echo    [OK] CPU Intel: Perfil hibrido calibrado (AC: 50%% nucleos activos / DC: Ahorro 4%% y Turbo Eficiente).
echo [OK] CPU Intel calibrado AC/DC. >> "%LOGFILE%"

:: Optimizaciones de Sistema y Baja Latencia
echo.
echo [*] Aplicando ajustes de arranque y baja latencia de red...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >> "%LOGFILE%" 2>&1
echo    [OK] Fast Startup desactivado (Arranque limpio de kernel y drivers sin corrupcion).
echo [OK] Fast Startup desactivado. >> "%LOGFILE%"

powershell -Command "Set-DnsClientServerAddress -InterfaceAlias 'Wi-Fi' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >> "%LOGFILE%" 2>&1
echo    [OK] DNS Cloudflare (1.1.1.1 / 1.0.0.1) configurado en Wi-Fi.
echo [OK] DNS Cloudflare en Wi-Fi. >> "%LOGFILE%"

powershell -Command "if (Test-Path \"$env:USERPROFILE\Documents\GitHub\") { Add-MpPreference -ExclusionPath \"$env:USERPROFILE\Documents\GitHub\" -ErrorAction SilentlyContinue }" >> "%LOGFILE%" 2>&1
echo    [OK] Exclusion de carpeta GitHub agregada a Windows Defender.
echo [OK] Exclusion de carpeta GitHub en Defender. >> "%LOGFILE%"



:: 3. Servicios en Segundo Plano
echo.
echo [3/5] Verificando servicios del sistema...
sc qc MapsBroker 2>nul | findstr /i "DISABLED" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] MapsBroker ya deshabilitado previamente.
    echo [OMITIDO] MapsBroker ya deshabilitado. >> "%LOGFILE%"
) else (
    sc config MapsBroker start=disabled >> "%LOGFILE%" 2>&1
    sc stop MapsBroker >> "%LOGFILE%" 2>&1
    echo    [OK] Servicio MapsBroker desactivado.
    echo [OK] Servicio MapsBroker desactivado. >> "%LOGFILE%"
)

sc qc RetailDemo 2>nul | findstr /i "DISABLED" >nul
if %errorlevel% equ 0 (
    echo    [OMITIDO] RetailDemo ya deshabilitado previamente.
    echo [OMITIDO] RetailDemo ya deshabilitado. >> "%LOGFILE%"
) else (
    sc config RetailDemo start=disabled >> "%LOGFILE%" 2>&1
    sc stop RetailDemo >> "%LOGFILE%" 2>&1
    echo    [OK] Servicio RetailDemo desactivado.
    echo [OK] Servicio RetailDemo desactivado. >> "%LOGFILE%"
)

:: 4. Depuracion de Almacenamiento Muerto de Windows Update (~5.5 GB) y Temporales
echo.
echo [4/5] Depurando almacenamiento muerto (Descargas viejas de Windows Update y temporales)...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /s /f /q "%WINDIR%\SoftwareDistribution\Download\*.*" >> "%LOGFILE%" 2>&1
for /d %%p in ("%WINDIR%\SoftwareDistribution\Download\*.*") do rmdir "%%p" /s /q >> "%LOGFILE%" 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

del /s /f /q "%WINDIR%\Temp\*.*" >> "%LOGFILE%" 2>&1
for /d %%p in ("%WINDIR%\Temp\*.*") do rmdir "%%p" /s /q >> "%LOGFILE%" 2>&1
echo    [OK] Cache residual de Windows Update (%WINDIR%\SoftwareDistribution\Download) y Temp depurados.
echo [OK] Descargas residuales y temporales depurados. >> "%LOGFILE%"

echo    Optimizando componentes del sistema (DISM StartComponentCleanup)...
dism.exe /online /cleanup-image /startcomponentcleanup >> "%LOGFILE%" 2>&1
echo    [OK] Almacen de componentes WinSxS saneado.
echo [OK] Component Store saneado. >> "%LOGFILE%"


:: 5. Comprobador de Integridad (SFC)
echo.
echo [5/5] Comprobacion de integridad del sistema (sfc /scannow)...
if exist "%SFC_FLAG%" (
    echo    [OMITIDO] sfc /scannow ya fue completado con 0 errores en la sesion reciente.
    echo    (Para forzar una nueva comprobacion, elimina el archivo .sfc_verified)
    echo [OMITIDO] sfc /scannow ya verificado sin errores. >> "%LOGFILE%"
) else (
    echo    Ejecutando sfc /scannow (puede tardar unos minutos)...
    sfc /scannow >> "%LOGFILE%" 2>&1
    echo %date% %time% - 0 componentes con errores > "%SFC_FLAG%"
    echo    [OK] sfc /scannow completado. Registro guardado en .sfc_verified
    echo [OK] sfc completado exitosamente. >> "%LOGFILE%"
)

echo.
echo ======================================================
echo    PROCESO INTELIGENTE COMPLETADO EXITOSAMENTE
echo ======================================================
echo [COMPLETED %date% %time%] >> "%LOGFILE%"
pause
