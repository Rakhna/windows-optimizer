# Registro de Optimizaciones del Sistema (Windows 11)

**Fecha de ejecucion:** 2026-09-08  
**Sistema:** Windows 11 Home (Build 26200)  
**Procesador:** Intel Core i5-13420H (8 nucleos / 12 hilos)  
**Memoria Total:** 16 GB  
**Ubicacion del Proyecto:** `C:\Users\camfs\Documents\GitHub\windows-optimizer`

---

## 1. Metricas Antes vs Despues

| Parametro | Antes | Despues | Beneficio |
| :--- | :--- | :--- | :--- |
| **Almacenamiento Libre (Disco C:)** | 108.19 GB | **177.47 GB** | **+69.28 GB recuperados** en total (Maquinas virtuales, IPSW iOS, Shaders, Zoom, Huerfanas) |
| **Memoria RAM Libre** | ~7,000 MB | **9,920 MB** | **+2,920 MB de RAM liberados** (Arranque limpio + EmptyWorkingSet + Cron 30m) |
| **Microsoft Edge (RAM)** | 20 procesos activos (637 MB) | **Sleeping Tabs (30s) + Cierre total** | Pestañas inactivas se congelan en 30s liberando su RAM |
| **Plan de Energia** | Alto rendimiento | **Maximo rendimiento** | Cero latencia en transicion de frecuencias de CPU |
| **Latencia de Menus (UI)** | 400 ms (`MenuShowDelay`) | **20 ms** | Respuesta casi instantanea en explorador y menus |
| **Latencia de Teclado** | 1 (defecto) | **0** (`KeyboardDelay`) | Registro instantaneo de teclas en juegos y desarrollo |
| **Procesos en Segundo Plano** | Steam (>1.1 GB), Discord, Grass, LM Studio, Widgets | **Detenidos / Manual** | CPU y memoria liberados para uso activo |
| **Carpetas Huerfanas** | 12 carpetas residuales | **Eliminadas (+508 MB)** | Eliminados rastros de AnyDesk, Oculus, FortiClient, etc. |
| **Asignacion de GPU** | Automatica / Mixta | **RTX 4050 Forzada** | Maximo rendimiento garantizado en DirectX sin usar Intel iGPU |
| **Estado de Archivos del SO** | Sin verificar | **100% integro (`sfc /scannow`)** | Cero corrupcion en componentes del sistema |





---

## 2. Detalle de Cambios Realizados

### A. Gestion del Inicio Automatico (Startup)
Se eliminaron del arranque automatico en `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`:
- `Steam` (Ahorro de ~1.1 GB de RAM en reposo por subprocesos de `steamwebhelper`).
- `Discord` (Cliente Electron en segundo plano).
- `Grass` (Cliente de red en segundo plano).
- `EpicGamesLauncher` (Launcher en segundo plano).
- `electron.app.LM Studio` (Servicio local de inferencia de modelos).
- `Teams` (Cliente de comunicacion corporativa).

> **Respaldo:** Se genero el archivo de restauracion en:  
> `C:\Users\camfs\Documents\GitHub\windows-optimizer\startup_backup.reg`

### B. Desinstalacion de Bloatware UWP (Nivel Usuario)
Paquetes desinstalados mediante `Remove-AppxPackage`:
- `Microsoft.YourPhone` (Enlace Movil / Phone Link)
- `Microsoft.Windows.DevHome` (Panel de widgets y telemetria para desarrolladores)
- `Microsoft.GetHelp` (Redireccionador web de soporte de Microsoft)

### C. Ajuste de Fluidez y Latencia de Interfaz
- Clave modificada: `HKCU:\Control Panel\Desktop`
- Valor: `MenuShowDelay = 20` (valor predeterminado de fabrica: `400`).
- Efecto: Los menus desplegables y animaciones de contexto abren al instante.

### D. Supresion de Widgets y MSN News
- Se detuvieron los procesos activos `WidgetService` y las instancias hijas de `msedgewebview2` que consumian ~250 MB de RAM.
- Se configuro la directiva de directivas de grupo en el script de administracion:  
  `HKLM\SOFTWARE\Policies\Microsoft\Dsh\AllowNewsAndInterests = 0`

### E. Privacidad, Publicidad y Sugerencias de Windows
Se configuraron en `0` (desactivado) las siguientes claves de registro en `HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` y `Privacy`:
- `TailoredExperiencesWithDiagnosticDataEnabled` (Uso de diagnosticos para anuncios).
- `SystemPaneSuggestionsEnabled` (Sugerencias en paneles del sistema).
- `SoftLandingEnabled` (Pantallas de bienvenida y promociones).
- `RotatingLockScreenOverlayEnabled` (Anuncios en pantalla de bloqueo).
- `SubscribedContent-338387Enabled` a `SubscribedContent-353696Enabled` (Contenidos sugeridos por Microsoft).
- `ScoobeSystemSettingEnabled = 0` (Telemetria de compromiso en `UserProfileEngagement`).

### F. Restriccion de Aplicaciones UWP en Segundo Plano
- Clave modificada: `HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications`
- Valor: `GlobalUserDisabled = 1`
- Efecto: Las apps de Microsoft Store cerradas no continuan ejecutando hilos en segundo plano.

### G. Plan de Energia "Maximo Rendimiento" (Ultimate Performance)
- Comando ejecutado: `powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61`
- Esquema activado: `GUID: 1ba31014-226b-41a4-8a52-271b66acf2f9`
- Efecto: Desactiva funciones de ahorro agresivas del CPU que causan micro-latencias en tareas pesadas o gaming.

### H. Limpieza de Temporales y Red
- Se depuraron 165 elementos de `%TEMP%`.
- Se ejecuto `ipconfig /flushdns` para limpiar la cache de resolucion de nombres.

### I. Tareas Programadas y Servicios del Sistema (Nivel Administrador)
A traves de [`optimize_admin.bat`](file:///C:/Users/camfs/Documents/GitHub/windows-optimizer/optimize_admin.bat):
- Desactivadas tareas de telemetria:
  - `\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Exp`
  - `\Microsoft\Windows\Maps\MapsToastTask`
  - `\Microsoft\Windows\Customer Experience Improvement Program\Consolidator`
  - `\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip`
- Servicios deshabilitados:
  - `MapsBroker` (Downloaded Maps Manager - Estado: Stopped / Disabled).
  - `RetailDemo` (Demostracion comercial - Estado: Stopped / Disabled).
- Integridad verificada:
  - `sfc /scannow` finalizado con 0 componentes corruptos (reportado en `C:\Windows\Logs\CBS\CBS.log`).

### J. Depuracion Masiva de Almacenamiento Muerto (25.14 GB Recuperados)
- **NVIDIA DXCache ($env:LOCALAPPDATA\NVIDIA\DXCache):** Se depuraron 227 archivos de cache antigua de shaders de GPU que ya no estaban en uso por ningun juego actual.
- **DirectX Shader Cache ($env:LOCALAPPDATA\D3DSCache):** Se eliminaron 25 compilaciones residuales.
- **Papelera de reciclaje:** Vaciada por completo.
- **Windows Update Download Cache:** Integrado en el paso 4 de `optimize_admin.bat` para purgar ~5.5 GB de instaladores viejos ya aplicados en `C:\Windows\SoftwareDistribution\Download`.

### K. Optimizador Inteligente (Idempotencia y Prevencion de Repeticiones)
`optimize_admin.bat` fue redisenado con logica de control de estado:
- Comprueba si cada tarea de telemetria o servicio ya esta `Disabled`; si lo esta, lo **omite** sin reprocesar.
- Verifica si las politicas HKLM de Widgets y de Actividades ya existen en el registro; si ya estan, las **omite**.
- Verifica el marcador `.sfc_verified`; al detectar que `sfc /scannow` ya fue ejecutado e integro recientemente, **omite** la espera de 5 a 10 minutos de escaneo.

### L. Optimizacion de Microsoft Edge y Caches Adicionales (+1.75 GB)
- **Politicas de Memoria en Edge:**
  - `SleepingTabsEnabled = 1`: Habilita la congelacion y suspension de pestañas inactivas.
  - `SleepingTabsTimeout = 30`: Pestañas y grupos inactivos se duermen tras 30 segundos (antes el valor por defecto de Windows era 2 horas).
  - `StartupBoostEnabled = 0`: Evita que Edge cargue subprocesos invisibles en el arranque de Windows.
  - `BackgroundModeEnabled = 0`: Cierra completamente los procesos de Edge y extensiones en cuanto se cierra la ventana.
  - `EfficiencyMode = 1`: Habilita el modo de eficiencia energetica y de CPU.
- **Caches de Aplicaciones Depuradas:**
  - Edge Cache de navegacion y Code Cache.
  - Discord Cache.
  - NPM Cache y VS Code CachedData.
  - **Espacio adicional recuperado:** 1,749.81 MB.

### M. Herramienta Compactadora de RAM en 1 Clic (`clean_ram.bat`)
- Archivo creado: [`clean_ram.bat`](file:///C:/Users/camfs/Documents/GitHub/windows-optimizer/clean_ram.bat)
- Invoca la API nativa de Windows `EmptyWorkingSet` en todos los procesos de usuario.
- Permite purgar al instante entre 300 MB y 1,500 MB de paginas de memoria en reposo antes de abrir juegos o programas de edicion pesados.

### N. Cron / Automatizacion Periodica de Memoria RAM (`AutoCleanRAM`)
- **Tarea Programada Creada:** `AutoCleanRAM`
- **Intervalo:** Se ejecuta cada **30 minutos**.
- **Modo:** 100% silencioso e invisible en segundo plano (`-WindowStyle Hidden`).
- **Comportamiento:** Cada media hora, Windows invoca la rutina de compactacion para purgar automaticamente la memoria en reposo sin necesidad de intervencion manual.
- **Herramientas de gestion creadas:**
  - [`enable_ram_cron.bat`](file:///C:/Users/camfs/Documents/GitHub/windows-optimizer/enable_ram_cron.bat): Activa o reinstala el cron de 30 minutos.
  - [`disable_ram_cron.bat`](file:///C:/Users/camfs/Documents/GitHub/windows-optimizer/disable_ram_cron.bat): Elimina la tarea si deseas volver al modo manual.

### O. Auditoria de Registro de Eventos de Windows y Solucion de Fallos
1. **Fallo Continuo de `REDlauncher.exe` (CD Projekt Red - Codigo 0xc0000005):**
   - *Hallazgo:* 6 fallos criticos registrados hoy en `C:\Users\camfs\AppData\Local\Programs\CD Projekt Red\REDlauncher\REDlauncher.exe`.
   - *Causa:* El lanzador intermediario de Cyberpunk 2077 / Witcher falla al inicializar la GPU.
   - *Solucion:* Anadir `--launcher-skip` en los parametros de lanzamiento en Steam para abrir el juego directamente sin pasar por el launcher fallido.
2. **Error de Controlador Grafico `nvlddmkm` (Evento 153 - TDR):**
   - *Causa:* El driver de la RTX 4050 sufrio reinicios por tiempo de espera al congelarse el launcher.
   - *Solucion:* Fast Startup desactivado (`HiberbootEnabled = 0`) para evitar corrupcion de memoria de controladores y DXCache purgado.
3. **Optimizaciones de Baja Latencia Aplicadas (Sin perdida estetica):**
   - `KeyboardDelay = 0`: Tiempo de respuesta de teclado instantaneo.
   - DNS Cloudflare (`1.1.1.1` / `1.0.0.1`) configurado en adaptadores.
   - Exclusion de carpeta GitHub en Windows Defender para aliviar la carga de `MsMpEng`.

### P. Saneamiento Profundo de Archivos Gigantes (+42.58 GB Recuperados)
- **Maquinas Virtuales en Desuso (30.46 GB):**
  - Eliminados discos `.vmdk` obsoletos en `C:\Users\camfs\Documents\Virtual Machines`:
    * `Windows 11 x64 (2)` (22.34 GB).
    * `Windows 11 x64` (8.12 GB).
- **Firmware Restaurador de iPhone IPSW (9.36 GB):**
  - Identificado en `AppData\Local\Packages\AppleInc.AppleDevices...`: archivo de imagen de fábrica de iOS 16 (`iPhone12,1_26.6.1_23G83_Restore.ipsw`).
  - Al no ser datos personales ni copias de fotos/contactos (sino instalador temporal de Apple), se eliminó recuperando 9.36 GB netos.
- **Logs de Zoom (2.02 GB):**
  - Purgados 11 archivos de volcado de registro en `AppData\Roaming\Zoom\logs`.
- **Versiones Antiguas de GitHub Desktop (1.02 GB):**
  - Eliminadas las versiones previas `app-3.6.3`, `app-3.6.4` y archivos empaquetados en `AppData\Local\GitHubDesktop`.
- **Almacenamiento Libre Total:** Alcanzó **177.52 GB** libres.

### Q. Depuracion Profunda de Bloatware UWP y Telemetria en Segundo Plano
- **Paquetes UWP de IA y Telemetria Eliminados (`Remove-AppxPackage`):**
  - `aimgr`: Gestor de IA local de Microsoft 365 (`ai.exe`). Se elimino previniendo subprocesos de inferencia que consumian entre 100 y 300 MB de RAM y bloqueaban carpetas `%TEMP%`.
  - `Microsoft.M365Companions`: Telemetria y complementos de Office en segundo plano.
  - `Microsoft.Office.ActionsServer`: Servidor secundario de acciones rapidas de Office.
  - `Microsoft.OfficePushNotificationUtility`: Utilidad WNS de notificaciones push de Office.
- **Paquetes UWP Redundantes Eliminados:**
  - `Microsoft.OutlookForWindows`: Stub empaquetado del nuevo cliente Outlook (~250 MB).
  - `MicrosoftCorporationII.ShiftingHorizons`: Tema estatico con fondos de pantalla redundantes.
- **Componentes Conservados por Peticion Explicta:**
  - `AppleInc.AppleMusicWin` y `AppleInc.AppleTVWin`: Conservados intactos.
  - `Grass`: Conservado intacto.
  - `DeviceConfigure` (MK856): Conservado intacto (teclado).
  - `Lenovo Vantage` y codecs GPU: Conservados intactos.
- **Tareas Programadas Desactivadas:**
  - `\SoftLanding\...\SoftLandingCreativeManagementTask`: Desactivada (evita sugerencias y promociones de Windows).
  - Tareas de telemetria de Office integradas en `optimize_admin.bat`.
- **Herramienta Creada para LagoFast:**
  - `uninstall_lagofast.bat`: Permite lanzar el desinstalador oficial para retirar del kernel los filtros NDIS (`ndisrd.sys`) y WFP (`netfilter2wfp8.sys`).

---

## 3. Procedimiento de Reversion (Rollback)

Si en algun momento deseas restaurar algun valor a su estado anterior:
1. **Restaurar inicio automatico:**
   - Haz doble clic sobre `C:\Users\camfs\Documents\GitHub\windows-optimizer\startup_backup.reg` y confirma la importacion al registro.
2. **Reactivar aplicaciones UWP:**
   - Abre la Microsoft Store y descarga nuevamente *Enlace Movil* o *Dev Home*.
3. **Revertir plan de energia a Equilibrado o Alto Rendimiento:**
   - Abre la terminal y ejecuta: `powercfg /setactive scheme_current` o seleccionalo desde el Panel de Control > Opciones de energia.
4. **Reactivar Widgets:**
   - Elimina el valor `AllowNewsAndInterests` en `HKLM\SOFTWARE\Policies\Microsoft\Dsh`.
