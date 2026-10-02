# Preferred LTE / NR network mode — investigation plan

**State: not yet tested.** Root access may expose privileged telephony controls, but it does not ensure persistent 4G-only or 5G-only operation on Samsung Exynos modems.

Goals:

- Determine the currently configured allowed-network-types mask per subscription and whether it is changed by Samsung's Settings UI, carrier policy, or telephony service.
- Observe behavior of permitted LTE-only or NR/LTE preferences while retaining voice/SMS and emergency-call capabilities.
- Establish whether selections survive radio toggles, SIM changes, a full restart, and software updates.
- Record what restores original network selection if connectivity is lost.

## Read-only baselines

```powershell
adb shell getprop gsm.version.baseband
adb shell getprop gsm.network.type
adb shell getprop ro.build.version.release
adb shell dumpsys telephony.registry > telephony-registry.txt
```

`dumpsys telephony.registry` can expose subscriber and network identifiers; **review and redact before publishing**. Android property outputs are informational and may not reflect actual allowed network masks.

## Precautions

NR-only can drop data or calls where standalone NR and VoNR are unavailable. Network preference settings can be overwritten by the modem, carrier configuration, or Android telephony stack. Avoid replacing modem firmware, touching EFS/NV calibration, or altering IMEI. The project will document only reversible and tested configuration changes once evidence is available.
