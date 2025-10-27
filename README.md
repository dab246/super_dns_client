# super_dns_client

A modern and lightweight Dart library for performing **DNS-over-HTTPS (DoH)** lookups.  
Supports multiple resolvers and can be easily integrated in Flutter or Dart server apps.

---

## 🚀 Features

- 🔍 Query **A, AAAA, CNAME, SRV, TXT** records via DoH  
- 🌐 Support for multiple resolvers (Google, Cloudflare, Quad9, OpenDNS, etc.)  
- 🧠 Simple high-level API for easy DNS lookups  
- 🧱 Built with `http`, `freezed`, and `json_serializable`  
- ✅ Null-safe and fully tested

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  super_dns_client: ^0.1.0
```

Then run:

```bash
dart pub get
```

---

## 💡 Usage

```dart
import 'package:super_dns_client/super_dns_client.dart';

void main() async {
  final client = DoHClient.resolver(DoHResolver.google);

  final response = await client.lookup('example.com', DnsRecordType.A);

  print('IPv4 addresses for example.com:');
  for (final record in response.records) {
    print('→ ${record.data}');
  }
}
```

---

## ⚙️ Supported DoH Resolvers

| Provider   | Endpoint URL                          |
|-------------|----------------------------------------|
| Google      | `https://dns.google/dns-query`         |
| Cloudflare  | `https://cloudflare-dns.com/dns-query` |
| Quad9       | `https://dns.quad9.net/dns-query`      |
| OpenDNS     | `https://doh.opendns.com/dns-query`    |

---

## 🧪 Run Tests

```bash
dart test
```

---

## 🪪 License

Licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for more details.

---

## ❤️ Contributing

Pull requests and feature suggestions are welcome.  
Open an issue at [GitHub Issues](https://github.com/dab246/super_dns_client/issues) if you find bugs or want to propose improvements.
