# Architecture & Technical Deep Dive

## 1. Memory Management: Working Set vs. Commit Charge

Windows manages process memory through several tiers:
- **Private Working Set:** Physical RAM pages currently actively addressed by a process.
- **Commit Charge:** Total virtual memory promised by the system to a process (backed by RAM or the paging file).
- **Standby Cache:** Pages of memory containing data not currently in active use, kept in RAM in case they are needed again.

### How `EmptyWorkingSet` Operates Safely
The RAM trimmer uses the Win32 API `EmptyWorkingSet(IntPtr hProcess)` exposed by `psapi.dll`.
- When invoked on a process handle, the Windows NT Virtual Memory Manager removes as many pages as possible from the working set of the specified process.
- The memory is **not destroyed** and the process is **not restarted**.
- Instead, idle memory pages are pushed to the standby list or pagefile.
- If the application needs that data again, the memory manager handles a soft page fault and maps it back transparently.
- This creates instant headroom for memory-intensive applications (such as modern games or developer build tools) without instability.

## 2. Permanent Deployment Target (`C:\WindowsOptimizer`)

To prevent scheduled tasks from failing when users clone the repository into temporary directories or move folders, `setup_cron.ps1` deploys the execution worker directly to:
```
C:\WindowsOptimizer\clean_ram.ps1
```
This isolates the OS-level cron schedule from Git branching, repository deletions, or folder renames.

## 3. GPU Stability & TDR Prevention (Event 153)

### The Fast Startup Trap
Windows Fast Startup (`HiberbootEnabled = 1`) hibernates kernel session data and driver states to `hiberfil.sys` instead of performing a clean shutdown. Over time, graphics drivers (such as NVIDIA `nvlddmkm.sys`) accumulate dirty pointer state, resulting in:
- Timeout Detection and Recovery (TDR) crashes (Event 153).
- Unhandled access violation exceptions (`0xc0000005`) in game launchers.

Disabling Fast Startup (`HiberbootEnabled = 0`) guarantees that on every boot, the Windows kernel and graphics drivers initialize in a clean state, completely resolving driver-induced micro-stutter and launcher crashes.

## 4. Microsoft Edge Background Polices

Even when closed, Chromium-based browsers like Edge often maintain background helper processes. We enforce registry policies under `HKLM\SOFTWARE\Policies\Microsoft\Edge`:
- `SleepingTabsEnabled = 1`: Inactive tabs sleep after 30 seconds.
- `StartupBoostEnabled = 0`: Disables invisible pre-launching at Windows startup.
- `BackgroundModeEnabled = 0`: Forcefully terminates all child processes when the last window is closed.
- `EfficiencyMode = 1`: Throttles background JavaScript timers.