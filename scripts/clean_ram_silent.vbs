Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""C:\WindowsOptimizer\clean_ram_silent.ps1""", 0, False