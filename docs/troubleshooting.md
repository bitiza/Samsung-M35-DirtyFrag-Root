# Troubleshooting KernelSU and DirtyFrag

## DirtyFrag says Rooted, KernelSU says Not installed

This happened during the initial investigation. DirtyFrag 1.05's `MainActivity` checks `new File("/dev/df").exists()` to enter its **Rooted** UI state. It also can restore its Verified progress display based on a previous recorded result. The `/dev/df` marker indicates that the temporary execution-hook path reached its mutex; **it is not equivalent to a working `su` interface**.

Source: [`MainActivity.java`](https://github.com/mitschud/DirtyFrag/blob/master/app/src/main/java/df/root/MainActivity.java) and [`exp.c`](https://github.com/mitschud/DirtyFrag/blob/master/app/src/main/jni/exp.c).

## Marker meaning (upstream implementation)

| Marker | Upstream interpretation |
| --- | --- |
| `/dev/df` | The libc++ execution hook acquired its one-shot mutex; processing continued. |
| `/dev/dfm0` | Kernel-side command exited successfully; native code reports `***SUCCESS***`, return code 0. |
| `/dev/dfm1` | `ksud` command failed; native code reports return code 1. |

`ls` or `stat` may return `Permission denied` under unprivileged ADB or the `run-as` SELinux domain, which does not establish file absence. By contrast, `No such file or directory` is different, but still requires attention to access restrictions and namespace context.

## Missing `su` on ADB

`adb shell su -c id` initially reported `su: inaccessible or not found`. KernelSU did subsequently load successfully and Shizuku ran in root mode, so **lack of a usable `su` from an unauthorized ADB shell is not a final determination**. Check the manager's **Superuser** tab and explicitly grant only apps you trust. Do not copy arbitrary `su` binaries into `/system`.

## KernelSU daemon not visible under `pidof ksud`

The successful capture included a transient `ksud::late_load` process with `uid=0`, and later module loading. A `pidof ksud` snapshot taken at another time may show nothing. Prefer a complete time-ordered logcat capture around boot.

## Status still says Rooted after reboot

In the tested configuration `df.root.BootReceiver` was listed under `enabledComponents`. When its receiver is enabled and Expert Mode is on, the app can run the exploit at `LOCKED_BOOT_COMPLETED`. This can recreate `/dev/df` following a real reboot. An enabled component is only a configuration state: confirm **actual execution** from a log entry such as `boot: android.intent.action.LOCKED_BOOT_COMPLETED`.

## Warnings about missing scripts/directories

During the successful run, `ksud` logged that some optional paths such as `/data/adb/service.d` and `/data/adb/late-load.d` did not exist. It nonetheless logged `kernelsu.ko loaded successfully!`, and the manager reported Working. Avoid treating optional script-directory warnings alone as fatal.

## Logs are missing

Android logcat buffers roll over; an extra soft reboot or late capture can lose earlier messages. Capture promptly after boot and filter by the exact `dfroot` tag and `KernelSU`. The Advanced log switch in DirtyFrag controls the in-app presentation; it does not guarantee new kernel diagnostics.

**Do not turn off SELinux, flash random modules, or repeatedly re-run the exploit to compensate for a missing log line.**
