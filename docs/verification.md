# Verification: what was actually established

## Target and sequence (2026-10-02)

Recorded device: Samsung Galaxy M35 5G, firmware `M356BXXU8DZE3`, kernel `5.15.189-android13-3-33470412`. The DirtyFrag 1.05 run used its `android13-5.15` kernel-object payload and a vendor-library staging path. Original, unredacted memory addresses and dynamically assigned ports are intentionally omitted here.

The initial app reported `Rooted` and `100% Verified`, but `adb shell su -c id` returned `/system/bin/sh: su: inaccessible or not found`. `pidof ksud` showed no visible process and KernelSU Manager initially said `Not installed`. These were useful observations, **not** proof that the kernel module was absent.

After a normal Power-menu restart, Android's logs demonstrated that the enabled DirtyFrag boot receiver had been launched. A subsequent full boot-log capture at approximately **08:21** showed:

```text
I dfroot   : boot: android.intent.action.LOCKED_BOOT_COMPLETED
I dfroot   : ksud staged to: /data/user_de/0/df.root/ksud
I dfroot   : * ko android13-5.15 (11384 bytes)
I dfroot   : patch #1 verify OK
I dfroot   : * triggering...
I dfroot   : libc++: mutex acquired, loading custom module
I KernelSU : ksud::late_load: [late-load start] pid=<redacted>, uid=0, gid=0, groups=[], selinux=u:r:kernel:s0
I KernelSU : ksud::late_load: Detected KMI: android13-5.15
I KernelSU : ksud::late_load: Loading kernelsu.ko for KMI android13-5.15...
I dfroot   : ***SUCCESS***
I dfroot   : boot: exploit rc=0
I KernelSU : ksud::late_load: kernelsu.ko loaded successfully!
I KernelSU : ksud::late_load: [after load_module] pid=<redacted>, uid=0, gid=0, groups=[], selinux=u:r:ksu:s0
I KernelSU : ksud::late_load: Restarting KernelSU Manager me.weishu.kernelsu...
```

Note that `boot: exploit rc=0` appears **before** the later `kernelsu.ko loaded successfully!` line. Interpreting the entire trace and the manager's subsequent state is more reliable than interpreting an isolated success marker.

The manager subsequently displayed **Working [Jailbreak mode]**, `LKM`, `32653-4 Custom`, and `SELinux: Enforcing`. Shizuku later showed `Version 13.6, root`, further corroborating privileged service capability. Root permissions still must be granted explicitly to apps.

## Run local diagnostics

On a Windows machine with platform-tools:

```powershell
adb devices
adb shell uname -r
adb shell cat /proc/uptime
adb shell getenforce
adb shell dumpsys package df.root | Select-String -Pattern 'BootReceiver|enabledComponents' -Context 0,3
adb logcat -d -b all -v threadtime > boot_full.txt
Get-Content .\boot_full.txt | Select-String -Pattern 'dfroot|KernelSU|ksud|late-load' | Out-File boot_filtered.txt
```

`boot_full.txt` includes unrelated apps and possibly personal information. Do not commit it to GitHub. `su` availability from `adb shell` is **not a sufficient test** of an authorized app's ability to gain root under KernelSU.

## Interpretation hierarchy

1. DirtyFrag's **Rooted** label: indicator only, not sufficient.
2. DirtyFrag native `rc=0`: indicates it saw its success marker, which is generated after `ksud late-load` command exit success.
3. KernelSU `kernelsu.ko loaded successfully!`: evidence the module was loaded.
4. Manager **Working [Jailbreak mode]**: evidence the manager recognizes active KernelSU.
5. An app that is specifically authorized in the KernelSU Superuser tab obtaining a root session: direct test of per-app superuser behavior (Shizuku observed running in root mode; individual VPN app permissions require separate validation).

## Limits

This was an observational experiment, not a measured success-rate study. These logs do not demonstrate VPN routing success, persistent modem network locks, behavior after firmware update, safety of auto soft-reboot, or a permanent boot image change.
