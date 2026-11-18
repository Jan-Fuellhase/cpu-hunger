$os = Get-CimInstance Win32_OperatingSystem
"RAM frei: $([math]::Round($os.FreePhysicalMemory/1MB,1)) GB von $([math]::Round($os.TotalVisibleMemorySize/1MB,1)) GB"
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command | Format-Table -Wrap -AutoSize
