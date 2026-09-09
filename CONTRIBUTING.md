# Contributing to Windows Optimizer

Thank you for your interest in improving Windows Optimizer! We welcome contributions that make Windows cleaner, faster, and more responsive while adhering to our strict core principles.

## Core Design Principles

Any proposed pull request must adhere to the following rules:
1. **Never Break Aesthetics:** Transparency (Mica, acrylic), smooth font rendering (ClearType), and UI window animations must never be disabled or degraded.
2. **Never Break System Integrity:** Do not remove or corrupt core components:
   - Microsoft Store (`Microsoft.WindowsStore`)
   - Windows Defender (`Microsoft.SecHealthUI`)
   - Windows Terminal & Core Utilities (Calculator, Photos, Notepad, Camera)
   - Audio, Bluetooth, and Wi-Fi subsystem drivers
   - Hardware video decoders (`AV1`, `HEVC`, `VP9`)
3. **Native APIs Over Third-Party Hooks:** Prefer Win32 APIs (e.g. `psapi.dll!EmptyWorkingSet`) and native PowerShell/DISM tooling.
4. **Idempotency:** Ensure all scripts check the current state before applying changes, making multiple runs safe.

## Development Workflow

1. Fork the repository and create a feature branch (`git checkout -b feat/my-improvement`).
2. Make your changes in `scripts/` or documentation.
3. Validate syntax and run test suites:
   ```powershell
   .\tests\Syntax.Tests.ps1
   .\tests\RamTrimmer.Tests.ps1
   ```
4. Commit with descriptive messages (e.g. `feat: add network buffer tuning`).
5. Open a Pull Request referencing any related issues.