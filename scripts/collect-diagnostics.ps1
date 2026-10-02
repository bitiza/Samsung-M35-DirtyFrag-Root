# Read-only ADB diagnostics for a local, authorized Android device.
# Do not publish complete logs without reviewing/redacting sensitive data.
param([string]$Destination = ".\DirtyFragLogs")
$ErrorActionPreference = 'Stop'
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    throw 'adb not found in PATH. Install Android platform-tools first.'
}
New-Item -ItemType Directory -Path $Destination -Force | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$dir = Join-Path $Destination $stamp
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$devices = & adb devices
$devices | Out-File (Join-Path $dir 'adb-devices.txt') -Encoding utf8
$online = @($devices | Select-String '\sdevice$').Count
if ($online -ne 1) { throw "Expected exactly one authorized connected device; found $online." }
& adb shell uname -r | Out-File (Join-Path $dir 'kernel.txt') -Encoding utf8
& adb shell getenforce | Out-File (Join-Path $dir 'selinux.txt') -Encoding utf8
& adb shell cat /proc/uptime | Out-File (Join-Path $dir 'uptime.txt') -Encoding utf8
& adb shell dumpsys package df.root | Select-String -Pattern 'BootReceiver|enabledComponents' -Context 0,3 | Out-File (Join-Path $dir 'receiver.txt') -Encoding utf8
$raw = Join-Path $dir 'boot-full-PRIVATE.txt'
& adb logcat -d -b all -v threadtime | Out-File $raw -Encoding utf8
Get-Content $raw | Select-String -Pattern 'dfroot|KernelSU|ksud|late-load' | Out-File (Join-Path $dir 'boot-filtered-REVIEW-BEFORE-SHARING.txt') -Encoding utf8
Write-Host "Saved diagnostic files in $dir"
Write-Warning 'Raw/filtered logcat can contain identifiers and private information. REVIEW and redact before publication.'
