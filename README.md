# 🧭 super_dns_client

A modern, lightweight, and **native-integrated** DNS resolver for Dart and Flutter —  
supporting both **DNS-over-HTTPS (DoH)** and traditional **UDP/TCP lookups**  
with **system-aware DNS discovery** across all major platforms.

Built for Flutter, Dart CLI, and backend apps.

---

## 🚀 Features

- 🔍 Query `A`, `AAAA`, `CNAME`, `SRV`, `TXT` records  
- 🌐 Supports **DoH** and **traditional UDP/TCP DNS**  
- 🧩 Native **System DNS detection** (macOS, Linux, Android, iOS)  
- ⚙️ **Public resolver fallback** with automatic switching  
- 💾 TTL-based SRV caching  
- 🧱 Built with `universal_io`, `super_raw`, and `super_ip`  
- ✅ Null-safe, CI-tested, production-ready

---

## 📦 Installation

```yaml
dependencies:
  super_dns_client: ^0.3.0
```

Then run:

```bash
dart pub get
```

---

## 💡 Example

```dart
import 'package:super_dns_client/super_dns_client.dart';
import 'package:super_dns_client/src/udp_tcp/system_udp_srv_client.dart';
import 'package:super_dns_client/src/udp_tcp/public_udp_srv_client.dart';

void main() async {
  // Example 1: DNS-over-HTTPS (Cloudflare)
  final doh = DnsOverHttps.cloudflare();
  final records = await doh.lookup('google.com');
  for (var ip in records) {
    print('DoH → ${ip.address}');
  }

  // Example 2: SRV lookup via System-configured DNS
  final systemClient = SystemUdpSrvClient();
  final systemRecords = await systemClient.lookupSrv('_jmap._tcp.example.com');
  for (var r in systemRecords) {
    print('SystemDNS → ${r.target}:${r.port}');
  }

  // Example 3: SRV lookup via Public DNS resolvers
  final publicClient = PublicUdpSrvClient();
  final publicRecords = await publicClient.lookupSrv('_jmap._tcp.example.com');
  for (var r in publicRecords) {
    print('PublicDNS(${r.resolverName}) → ${r.target}:${r.port}');
  }
}
```

---

## ⚙️ Platform-specific System DNS Detection

| Platform | Method | Description |
|-----------|---------|-------------|
| **Android** | `ConnectivityManager.getLinkProperties()` | The plugin uses a native Kotlin bridge to fetch DNS servers from the currently active network interface. Requires `ACCESS_NETWORK_STATE` permission. |
| **iOS** | `res_ninit()` via Objective-C helper | Calls the BSD resolver API to enumerate system DNS servers (`/etc/resolv.conf` equivalent). |
| **macOS / Linux** | File parsing | Reads `/etc/resolv.conf` for configured nameservers. |
| **Web** | Not supported | Browsers restrict raw DNS queries; DoH should be used instead. |

> 🧠 System detection is handled automatically by `SystemUdpSrvClient`,  
> which internally uses `PlatformSystemDns` to bridge native resolvers.

---

## ⚙️ Available DNS Resolvers

### 🔸 DNS-over-HTTPS (DoH)
| Provider   | Endpoint URL |
|-------------|------------------------------|
| Google      | `https://dns.google/dns-query` |
| Cloudflare  | `https://cloudflare-dns.com/dns-query` |
| Quad9       | `https://dns.quad9.net/dns-query` |
| AdGuard     | `https://dns.adguard-dns.com/dns-query` |
| Mullvad     | `https://doh.mullvad.net/dns-query` |
| Yandex      | `https://dns.yandex.com/dns-query` |
| OpenDNS     | `https://doh.opendns.com/dns-query` |

### 🔸 Traditional (UDP/TCP)
- System resolvers from platform configuration (Android, iOS, Linux, macOS)
- Public resolvers (Quad9, AdGuard, Yandex, OpenDNS, Cloudflare)
- TCP fallback for truncated UDP responses

---

## 🧪 Run Tests

```bash
dart test
```

---

## 🌍 Example Output

```
DnsOverHttps.cloudflare::SRV → _jmap._tcp.example.com → jmap.example.com:443
SystemUdpSrvClient::SRV → example.com:443
PublicUdpSrvClient(quad9)::SRV → jmap.example.com:443
```

---

## 🧠 Summary

| Feature | Status |
|----------|---------|
| DNS-over-HTTPS | ✅ |
| UDP/TCP resolver | ✅ |
| System DNS detection (native) | ✅ |
| Public resolver fallback | ✅ |
| TTL cache | ✅ |
| IPv6 support | ✅ |
| Android native bridge | ✅ |
| iOS native bridge | ✅ |

---

## 🪪 License

Licensed under the **MIT License**.  
See [LICENSE](LICENSE) for details.

---

## ❤️ Contributing

Pull requests and ideas are welcome!  
Open an issue or PR at [GitHub Issues](https://github.com/dab246/super_dns_client/issues).

---

[![pub package](https://img.shields.io/pub/v/super_dns_client.svg)](https://pub.dev/packages/super_dns_client)
[![Dart](https://github.com/dab246/super_dns_client/actions/workflows/test.yml/badge.svg)](https://github.com/dab246/super_dns_client/actions)
