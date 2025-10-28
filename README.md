# 🧭 super_dns_client

A modern and lightweight Dart library for performing **DNS lookups** via  
🔹 **DNS-over-HTTPS (DoH)** and  
🔹 **traditional UDP/TCP resolvers** — including **System** and **Public SRV** discovery.

Built for Flutter, Dart CLI, and backend apps.

---

## 🚀 Features

- 🔍 Query `A`, `AAAA`, `CNAME`, `SRV`, `TXT` records  
- 🌐 Supports both **DoH** and **traditional UDP/TCP DNS**  
- ⚙️ Auto-detects **System-configured DNS** (macOS, Linux, Android, iOS)  
- 🧩 Public resolver support: Quad9, AdGuard, Yandex, OpenDNS, Cloudflare, Google, Mullvad, etc.  
- 💾 Built-in TTL-based SRV cache for performance  
- 🧱 Built with `universal_io`, `super_raw`, and `super_ip`  
- ✅ Null-safe, well-tested, CI-integrated

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
  final systemRecords = await systemClient.lookupSrv('_jmap._tcp.linagora.com');
  for (var r in systemRecords) {
    print('SystemDNS → ${r.target}:${r.port}');
  }

  // Example 3: SRV lookup via Public DNS resolvers
  final publicClient = PublicUdpSrvClient();
  final publicRecords = await publicClient.lookupSrv('_jmap._tcp.linagora.com');
  for (var r in publicRecords) {
    print('PublicDNS(${r.resolverName}) → ${r.target}:${r.port}');
  }
}
```

---

## ⚙️ Available DNS Resolvers

### 🔸 DNS-over-HTTPS (DoH)
| Provider   | Endpoint URL                          |
|-------------|----------------------------------------|
| Google      | `https://dns.google/dns-query`         |
| Cloudflare  | `https://cloudflare-dns.com/dns-query` |
| Quad9       | `https://dns.quad9.net/dns-query`      |
| AdGuard     | `https://dns.adguard-dns.com/dns-query` |
| Mullvad     | `https://doh.mullvad.net/dns-query`    |
| Yandex      | `https://dns.yandex.com/dns-query`     |
| OpenDNS     | `https://doh.opendns.com/dns-query`    |

### 🔸 Traditional (UDP/TCP)
- System-configured resolvers (`/etc/resolv.conf`, Android `getprop`, iOS fallback)
- Public resolvers (Quad9, AdGuard, Yandex, OpenDNS)
- TCP fallback if UDP is truncated or timed out

---

## 🧪 Run Tests

```bash
dart test
```

---

## 🪪 License

Licensed under the **MIT License**.  
See [LICENSE](LICENSE) for details.

---

## ❤️ Contributing

Pull requests and ideas are welcome!  
Open an issue or PR at [GitHub Issues](https://github.com/dab246/super_dns_client/issues).

---

## 🌟 Example Output

```
DnsOverHttps.cloudflare::SRV → _jmap._tcp.linagora.com → jmap.linagora.com:443
SystemUdpSrvClient::SRV → linagora.com:443
PublicUdpSrvClient(quad9)::SRV → jmap.linagora.com:443
```

---

## 🧠 Summary

| Feature | Status |
|----------|---------|
| DoH (Google/Cloudflare) | ✅ |
| Binary DoH (Quad9, Mullvad) | ✅ |
| UDP/TCP SRV resolver | ✅ |
| System DNS detection | ✅ |
| Public resolver list | ✅ |
| TTL cache | ✅ |
| IPv6 support | ✅ |

---

> ✨ **Since v0.3.0**: `super_dns_client` is now a **hybrid DNS resolver** supporting  
> both DoH and UDP/TCP SRV record lookups with automatic fallback.

---

[![pub package](https://img.shields.io/pub/v/super_dns_client.svg)](https://pub.dev/packages/super_dns_client)
[![Dart](https://github.com/dab246/super_dns_client/actions/workflows/test.yml/badge.svg)](https://github.com/dab246/super_dns_client/actions)
