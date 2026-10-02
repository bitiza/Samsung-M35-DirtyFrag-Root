# Boot receiver and runtime persistence

This workflow is **ephemeral runtime root**, not permanent firmware modification. The test did **not** flash `boot.img`, modify the bootloader, or install a new recovery.

DirtyFrag's manifest declares a `BootReceiver` that is **disabled by default**, but the application's **Autorun** option can enable it. The tested device's `dumpsys package df.root` showed:

```text
enabledComponents:
    df.root.BootReceiver
```

A successful boot trace then showed Android starting `df.root/df.root.BootReceiver` for `android.intent.action.LOCKED_BOOT_COMPLETED` and the receiver logging `boot: exploit rc=0`.

## What is and isn't persistent

- The app, its preferences, and enabled receiver remain installed across reboot unless reset or changed.
- A normally restarted kernel does not retain arbitrary loadable modules merely because they were loaded into the preceding kernel session.
- With Autorun enabled, DirtyFrag **attempts to run again after boot**. This is automatic re-exploitation, **not** a permanently rooted boot image.
- The **Auto reboot** setting controls an optional **additional soft reboot** after a boot-time run. It was disabled for the decisive captured success trace (`soft_reboot: false`).
- Whether future re-exploitation continues to work may change with firmware updates or boot conditions.

## Safety

Experimental automatic exploitation has documented boot-loop hazards. During troubleshooting, prefer **Auto reboot OFF** and keep reliable ADB access. Back up important data. Do not switch both settings on without understanding the risks and a recovery path. Firmware updates can invalidate assumptions.

See [BootReceiver.java](https://github.com/mitschud/DirtyFrag/blob/master/app/src/main/java/df/root/BootReceiver.java) and [ExploitRunner.java](https://github.com/mitschud/DirtyFrag/blob/master/app/src/main/java/df/root/ExploitRunner.java).
