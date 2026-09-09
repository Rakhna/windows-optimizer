# Windows Optimizer & Memory Manager

> Lightweight, safe, and aesthetic-preserving optimization suite for Windows 10 & 11.  
> Reclaims gigabytes of dead storage, compacts working set RAM, reduces input latency, and strips telemetry without breaking visual effects or system integrity.

---

## Overview & Philosophy

Most Windows "optimizer" scripts break essential system features: they corrupt the Microsoft Store, disable Windows Defender, break Bluetooth or audio drivers, or strip visual transparency and animations.

**Windows Optimizer** is engineered with a strict safety-first philosophy:
- **Zero Aesthetic Compromises:** Mica, acrylic blur, font smoothing, and window animations remain 100% intact.
- **Protected Core Components:** Microsoft Store, Windows Defender, Windows Terminal, Photos, Calculator, Audio/Bluetooth stacks, and GPU video codecs (`AV1`, `HEVC`, `VP9`) are strictly protected.
- **Native Win32 APIs:** Uses native Windows C# interop (`psapi.dll!EmptyWorkingSet`) rather than risky third-party memory hooks.
- **Idempotency:** Scripts check current system states and skip operations that have already been applied.

---

## Key Features

### 1. Dynamic Working Set RAM Compactor
- **Script:** `clean_ram.bat` / `scripts/clean_ram.ps1`
- **How it works:** Iterates across running user processes and invokes the Win32 API `EmptyWorkingSet` from `psapi.dll`.
- **Result:** Safely flushes idle pages to standby cache, instantly freeing between **500 MB and 3,000 MB of RAM** without terminating applications.

### 2. Silent RAM Cron Automation
- **Install:** `enable_ram_cron.bat` / `scripts/setup_cron.ps1`
- **Uninstall:** `disable_ram_cron.bat`
- **How it works:** Registers a native Windows Task Scheduler task (`AutoCleanRAM`) that runs silently every **30 minutes** (`-WindowStyle Hidden`).
- **Result:** Keeps memory usage contained automatically throughout long gaming sessions or development workloads.

### 3. Idempotent System & Latency Optimizer
- **Script:** `optimize_admin.bat` (Run as Administrator)
- **Features:**
  - **Telemetry Neutralization:** Disables non-essential background tasks (`Compatibility Appraiser`, `CEIP Consolidator`, `MapsToastTask`, Office telemetry).
  - **Edge RAM Policy:** Enforces Sleeping Tabs after 30 seconds, disables background extensions on close, and enables Efficiency Mode.
  - **UI Responsiveness:** Reduces `MenuShowDelay` from 400 ms to 20 ms and sets `KeyboardDelay` to 0 for instant context menus and input response.
  - **Stability & TDR Prevention:** Disables Fast Startup (`HiberbootEnabled = 0`) to prevent kernel driver memory corruption and GPU TDR crashes (`nvlddmkm` Event 153).
  - **Dead Storage Reclamation:** Safely purges old Windows Update installers (`SoftwareDistribution\Download`), cleans `%WINDIR%\Temp`, and runs DISM WinSxS Component Store cleanup (`/StartComponentCleanup`).

### 4. GPU Real-Time Telemetry & Thermal Tracker
- **Script:** `monitor_gpu.bat` / `scripts/monitor_gpu.ps1`
- **Features:** Real-time HUD querying `nvidia-smi` every second. Tracks GPU Temperature, Power Draw (Watts), Core/Memory Clocks, VRAM allocation, and alerts on thermal throttling thresholds (>85Â°C).

### 5. Safe UWP Debloater
- **Script:** `scripts/debloat_uwp.ps1`
- **Features:** Curated uninstallation of non-essential Windows 10/11 apps (Cortana, Solitaire, Bing News, DevHome, Phone Link, Office push stubs). Includes `-DryRun` mode for previewing removals.

---

## Project Structure

```
windows-optimizer/
â”œâ”€â”€ clean_ram.bat            # 1-Click manual RAM working set cleaner
â”œâ”€â”€ enable_ram_cron.bat      # 1-Click installer for 30-minute background RAM cron
â”œâ”€â”€ disable_ram_cron.bat     # 1-Click uninstaller for the background RAM cron
â”œâ”€â”€ optimize_admin.bat       # 1-Click elevated system & storage optimizer
â”œâ”€â”€ monitor_gpu.bat          # 1-Click NVIDIA GPU telemetry monitor
â”œâ”€â”€ scripts/
â”‚   â”œâ”€â”€ clean_ram.ps1        # Win32 EmptyWorkingSet memory compactor engine
â”‚   â”œâ”€â”€ setup_cron.ps1       # Task Scheduler registration engine
â”‚   â”œâ”€â”€ debloat_uwp.ps1      # Safe UWP package uninstaller
â”‚   â””â”€â”€ monitor_gpu.ps1      # NVIDIA real-time metrics monitor
â”œâ”€â”€ docs/
â”‚   â””â”€â”€ OPTIMIZATION_LOG.md  # Detailed benchmark & real-world test log
â”œâ”€â”€ .gitignore               # Excludes logs, caches, and machine-specific files
â”œâ”€â”€ LICENSE                  # MIT License
â””â”€â”€ README.md
```

---

## Quick Start

### Option A: 1-Click RAM Cleaning
Double-click `clean_ram.bat`. A console window will appear, compact idle process memory, display the freed megabytes, and exit on keypress.

### Option B: Set and Forget (Automatic 30-Min Cron)
Double-click `enable_ram_cron.bat`. Windows Task Scheduler will manage memory silently in the background. To remove it at any time, double-click `disable_ram_cron.bat`.

### Option C: Complete System Optimization
Right-click `optimize_admin.bat` and select **Run as administrator**. Follow the on-screen progress as it applies group policies, optimizes browser memory, and cleans the component store.

---

## Real-World Benchmark Results

Tested on Windows 11 (Intel Core i5-13420H / NVIDIA RTX 4050 Laptop / 16 GB RAM):

| Metric | Before | After | Total Impact |
| :--- | :--- | :--- | :--- |
| **Free Storage (C:)** | 108.19 GB | **177.52 GB** | **+69.33 GB Reclaimed** |
| **Available RAM** | ~7,000 MB | **9,920 MB** | **+2,920 MB Available** |
| **Menu Latency** | 400 ms | **20 ms** | 95% latency reduction |
| **Keyboard Delay** | 1 (default) | **0 (instant)** | 0 ms input debounce delay |
| **System Integrity** | Unchecked | **100% Validated** | Verified 0 corruption via SFC |

For detailed test logs, see [`docs/OPTIMIZATION_LOG.md`](docs/OPTIMIZATION_LOG.md).

---

## License

This project is licensed under the [MIT License](LICENSE).