$cores = [Environment]::ProcessorCount
$up = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
Write-Host "Logische CPU-Kerne: $cores | Laufzeit seit echtem Neustart: $($up.Days)d $($up.Hours)h $($up.Minutes)m" -ForegroundColor Yellow
Write-Host "Messe 3 Sekunden..." -ForegroundColor Cyan

$t1 = Get-Date
$p1 = @{}
Get-Process | ForEach-Object { if ($null -ne $_.CPU) { $p1[$_.Id] = [double]$_.CPU } }
Start-Sleep -Seconds 3
$dt = ((Get-Date) - $t1).TotalSeconds

$list = Get-Process | ForEach-Object {
    $cpuNow = if ($null -ne $_.CPU) { [double]$_.CPU } else { 0 }
    $delta = if ($p1.ContainsKey($_.Id) -and $cpuNow -ge $p1[$_.Id]) { $cpuNow - $p1[$_.Id] } else { 0 }
    [PSCustomObject]@{
        Name = $_.ProcessName
        LivePct = ($delta / ($dt * $cores)) * 100
        TotalSec = $cpuNow
        RamMB = $_.WorkingSet64 / 1MB
    }
}

Write-Host "`n=== TOP 12: LIVE CPU (gerade eben) ===" -ForegroundColor Cyan
$list | Group-Object Name | ForEach-Object {
    [PSCustomObject]@{
        App = $_.Name
        Instanzen = $_.Count
        Live_CPU_Prozent = [math]::Round(($_.Group | Measure-Object LivePct -Sum).Sum, 1)
        RAM_MB = [math]::Round(($_.Group | Measure-Object RamMB -Sum).Sum, 0)
    }
} | Sort-Object Live_CPU_Prozent -Descending | Select-Object -First 12 | Format-Table -AutoSize | Out-Host

Write-Host "=== TOP 12: DAUER-HUNGER (gesamte CPU-Zeit seit Start) ===" -ForegroundColor Cyan
$list | Group-Object Name | ForEach-Object {
    [PSCustomObject]@{
        App = $_.Name
        Instanzen = $_.Count
        Gesamt_CPU_Min = [math]::Round(($_.Group | Measure-Object TotalSec -Sum).Sum / 60, 1)
        RAM_MB = [math]::Round(($_.Group | Measure-Object RamMB -Sum).Sum, 0)
    }
} | Sort-Object Gesamt_CPU_Min -Descending | Select-Object -First 12 | Format-Table -AutoSize | Out-Host
