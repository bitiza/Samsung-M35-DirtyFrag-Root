# VPN connection sharing over mobile hotspot — test plan

**State: not yet verified end to end on this device.** Root via KernelSU and Shizuku's root mode were demonstrated; that does **not** demonstrate VPN forwarding for every VPN application.

The intended route is:

```text
4G/5G uplink -> Galaxy M35 -> VPN client tunnel -> NAT/tethering -> Wi-Fi hotspot client
```

## Trial procedure

1. Ensure KernelSU Manager reports **Working**.
2. Install [VPN Hotspot by Mygod](https://github.com/Mygod/VPNHotspot) from an official release.
3. Open KernelSU → **Superuser**, find VPN Hotspot, and authorize it. Restart the app if it previously reported `Root shell is not available`.
4. Connect a normal Android VPN (e.g., WireGuard, OpenVPN, a VpnService-based client). VPN Hotspot previously reported `Auto detect system VPN (current: ∅)` when no usable VPN interface was present.
5. Turn on Samsung's Mobile Hotspot, open VPN Hotspot's **Tethering** tab, and inspect available downstream interfaces.
6. Enable forwarding for the identified hotspot interface and run a controlled test with a client laptop/phone.
7. Compare public IPv4 address **on the phone over the VPN** versus **on the downstream client**. Test DNS resolvers and IPv6; an IPv4 match alone does not guarantee no leaks.
8. Disable VPN temporarily and repeat to assess fallback behavior; do not assume a kill switch is provided.

## Starting settings observed

| VPN Hotspot item | Earlier observed value | Notes |
| --- | --- | --- |
| Upstream | `Auto detect system VPN (current: ∅)` | No active system VPN was detected at screenshot time. |
| Fallback upstream | `wlan0` | At screenshot time phone default appeared to be Wi-Fi. Avoid unintended non-VPN fallback. |
| IPv4 masquerade | `Simple` | Initial setting; behavior not verified. |
| IPv6 | `Block` | Sensible initial test configuration, then confirm empirically. |
| Root | Initially `Root shell is not available` | Per-app KernelSU authorization still needed. |

## Validation checklist

- [ ] VPN Hotspot receives and retains KernelSU superuser authorization.
- [ ] Hotspot clients obtain IP, gateway, and DNS settings.
- [ ] Internet connection works when VPN is active.
- [ ] Client public IPv4 equals intended VPN egress address.
- [ ] Client DNS queries use intended resolvers, with no leaks.
- [ ] IPv6 is appropriately blocked or tunneled.
- [ ] VPN interruption does not silently leak traffic over a fallback uplink.
- [ ] VPN-specific differences documented separately (client name/version/transport).

Avoid manual firewall changes until interface discovery and controlled tests are complete.
