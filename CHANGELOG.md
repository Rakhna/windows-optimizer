# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-08

### Added
- **Dynamic RAM Working Set Compactor:** Native C# P/Invoke calling `psapi.dll!EmptyWorkingSet`.
- **Automated Silent Cron:** Windows Task Scheduler task (`AutoCleanRAM`) running every 30 minutes.
- **Permanent Deployment Target:** Deploys permanent engine to `C:\WindowsOptimizer\` ensuring resilience against repository relocations.
- **System Optimizer (`optimize_admin.bat`):**
  - Group Policy tweaks for Edge memory management (Sleeping Tabs in 30s, background mode disabled).
  - Telemetry tasks disabled (`Compatibility Appraiser`, `CEIP Consolidator`, `MapsToastTask`, Office telemetry).
  - UI responsiveness tuning (`MenuShowDelay = 20`, `KeyboardDelay = 0`).
  - Fast Startup disabled to eliminate TDR resets (`nvlddmkm` Event 153).
  - Component Store cleanup via DISM (`/StartComponentCleanup`) and Windows Update cache purging.
- **NVIDIA GPU Monitor:** Real-time console HUD querying `nvidia-smi` every second for thermal and power metrics.
- **Safe UWP Debloater:** Clean uninstallation engine with `-DryRun` support.
- **Test Suite:** Automated AST syntax verification and RAM trimmer unit tests.
- **GitHub Infrastructure:** CI workflows, issue templates, PR template, and comprehensive documentation.