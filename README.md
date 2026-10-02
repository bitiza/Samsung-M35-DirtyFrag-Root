# Samsung Galaxy M35 5G — DirtyFrag / KernelSU Runtime Root

> **Community research notes — tested 2026-10-02.** Documentation of a working *runtime* KernelSU load via DirtyFrag on one Samsung Galaxy M35 5G. This repository contains **no exploit binaries, modified kernels, or firmware dumps**.

## Verified device

| Parameter | Observed value |
| --- | --- |
| Model | Samsung Galaxy M35 5G (SM-M356B family) |
| Firmware / build | `M356BXXU8DZE3` |
| Kernel release | `5.15.189-android13-3-33470412` |
| DirtyFrag app | `1.05` (upstream fork: [mitschud/DirtyFrag](https://github.com/mitschud/DirtyFrag)) |
| KernelSU manager | `v3.3.0-52-g08a3b087 (32653-4)` (displayed) |
| KernelSU version / mode | `32653-4 (Custom)`; **Working [Jailbreak mode]**, **LKM** |
| SELinux (observed after load) | `Enforcing` |
| Shizuku (observed) | `13.6`, **root** mode |
| Bootloader | No bootloader unlock or boot-image patch was performed in this documented test. Bootloader lock state was not independently audited. |

**Scope:** these results apply to the exact tested configuration; other Samsung builds, Android patch levels, or KMI variants may behave differently. The approach relies on a security vulnerability, not a manufacturer-supported rooting method.

## Evidence summary

1. DirtyFrag's boot receiver was enabled and started by Android after a user-requested restart.
2. Its logger recorded `***SUCCESS***` and `boot: exploit rc=0`.
3. KernelSU's late-load log showed an initial **UID 0** process and `kernelsu.ko loaded successfully!`.
4. KernelSU Manager subsequently displayed **Working [Jailbreak mode]**, **LKM**.
5. Shizuku reported it was running in **root** mode.

The early troubleshooting was significant: the DirtyFrag app displayed **Rooted** while KernelSU Manager initially displayed **Not installed**. Source inspection showed that DirtyFrag's Rooted UI can be based on the `/dev/df` marker and that its progress display can also reflect a saved result. The UI status alone is **not** proof of a functional superuser environment.

See [sanitized evidence excerpt](logs/boot-evidence-sanitized.txt), [verification procedure](docs/verification.md), and [troubleshooting](docs/troubleshooting.md).

## Reproducing the verification (without modifying firmware)

**Prerequisites:** the exact device/build, a working ADB connection, the upstream DirtyFrag APK, and the compatible KernelSU Manager linked by the DirtyFrag project. Understand the risk of crashing or soft-bricking the device; back up data first. Obtain applications from their official upstream projects and verify their provenance.

The experiment used the original upstream app interface; no exploit code or modified executable is distributed here. The high-level recorded procedure was:

1. Install the matching KernelSU Manager and DirtyFrag 1.05 from upstream sources; open both to record their starting status.
2. Run DirtyFrag manually only after reviewing upstream instructions and device compatibility. Its logger stages `ksud`, patches the page cache, triggers the module-loading chain, and performs cleanup.
3. Confirm kernel-side activity using Android's system log and the manager **rather than trusting DirtyFrag's 'Rooted' label**.
4. In KernelSU Manager, explicitly grant root to trusted apps when required. Apps may initially say “root shell not available” even when the kernel module is working.
5. For automatic execution at startup, DirtyFrag has a separate **Autorun** receiver. Experimental boot-time execution and the **Auto reboot** toggle carry boot-loop risk; leave Auto reboot **OFF** during diagnostics. Avoid repeated triggering once root is active.

**Non-invasive ADB diagnostics (Windows PowerShell):**

```powershell
adb devices
adb shell uname -r
adb shell getenforce
adb shell dumpsys package df.root | Select-String -Pattern 'BootReceiver|enabledComponents' -Context 0,3
adb logcat -d -b all -v threadtime > boot_full.txt
Get-Content .\boot_full.txt | Select-String -Pattern 'dfroot|KernelSU|ksud|late-load' | Out-File .\boot_filtered.txt
```

**Do not publish `boot_full.txt` without redacting** device IDs, serial numbers, IMSIs, phone numbers, IP addresses, tokens, private paths, and other app logs. Refer to [verification](docs/verification.md) for how to interpret the results.

## Practical follow-up projects

- [VPN tethering over Wi-Fi hotspot](docs/vpn-hotspot.md): root has been demonstrated; **forwarding all VPN apps, hotspot DNS/IPv6 behavior, and downstream exit-IP tests have not yet been documented as verified**.
- [Preferred 4G/5G network mode](docs/network-mode.md): root may enable additional telephony controls; **persistent LTE-only/NR-only configuration has not yet been tested** on this build. NR-only may disable calls or connectivity depending on carrier and VoNR support.

## Contents

- [`docs/verification.md`](docs/verification.md): stepwise observation and clean ADB/logcat checks.
- [`docs/troubleshooting.md`](docs/troubleshooting.md): misleading status, missing `su`, SELinux, boot receiver, and module logs.
- [`docs/boot-behavior.md`](docs/boot-behavior.md): receiver registration, markers, and soft-reboot caveats.
- [`docs/vpn-hotspot.md`](docs/vpn-hotspot.md): VPN routing test plan and leak checks.
- [`docs/network-mode.md`](docs/network-mode.md): network locking investigation plan.
- [`logs/boot-evidence-sanitized.txt`](logs/boot-evidence-sanitized.txt): selected lines transcribed from the successful run.
- [`scripts/collect-diagnostics.ps1`](scripts/collect-diagnostics.ps1): read-only local diagnostic collector.

## Upstream credits and references

- [mitschud/DirtyFrag](https://github.com/mitschud/DirtyFrag) — DirtyFrag 1.05 app fork and mechanism description.
- [diabl0w/KernelSU](https://github.com/diabl0w/KernelSU) — custom KernelSU fork referenced by DirtyFrag.
- [tiann/KernelSU](https://github.com/tiann/KernelSU) — original KernelSU project.
- [Mygod/VPNHotspot](https://github.com/Mygod/VPNHotspot) — VPN tethering application (root required).
- [RikkaApps/Shizuku](https://github.com/RikkaApps/Shizuku) — Android API access service, tested in root mode.

## Responsible use and limitations

This is a single-device observational report, **not** an endorsement of exploiting production devices. A kernel exploit bypasses OS security boundaries and carries privacy, integrity, stability, warranty, and update-related risks. Do not treat a “Working” screen as an assurance that the phone is secure. Do not install untrusted modules or grant root indiscriminately. No claim is made about exploit reliability, persistence across updates, bypass of device security services, VPN forwarding compatibility, or persistent modem locks beyond the explicitly observed evidence.

## License

Documentation and original helper script: [MIT License](LICENSE). Upstream software retains its original licenses; no upstream executable is redistributed here.