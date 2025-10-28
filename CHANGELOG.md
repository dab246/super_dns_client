# Changelog

## 0.3.2

### Fixed
- Replaced all `dart:io` imports with `universal_io` to support Flutter Web builds.
- Fixed type mismatch error between `dart:io` and `universal_io` `InternetAddress` classes.
- Ensured `DnsClient` and related classes compile correctly on both mobile and web platforms.

## 0.3.1

### 🔧 Public Exports
- Exported all new SRV-related classes and clients in `super_dns_client.dart`:
  - `BaseUdpSrvClient`
  - `SystemUdpSrvClient`
  - `PublicUdpSrvClient`
  - `SrvRecord`
  - `DnsResolver`
  - `DnsClient`

### 🧩 Improvements
- Ensured all new resolvers and models are available for external import.
- Minor cleanup and final formatting before release.

## 0.3.0

### ✨ New Features
- Added `BaseUdpSrvClient` abstract class for shared SRV lookup logic.
- Implemented:
  - `SystemUdpSrvClient`: queries SRV records via system-configured DNS (UDP → TCP fallback).
  - `PublicUdpSrvClient`: queries SRV records via public resolvers (Quad9, AdGuard, Yandex, OpenDNS, etc.).
  - `DnsOverHttps.lookupSrvMulti()`: sequential SRV lookup (Google → Cloudflare fallback).
  - `DnsOverHttps.lookupSrvParallel()`: parallel SRV lookup (runs both resolvers simultaneously).
- Added `SrvRecord` model for typed SRV response handling instead of generic Map.
- Improved example `dns_client_example.dart` to demonstrate all client types:
  - System resolver
  - Public resolver
  - DoH (Google, Cloudflare, Mullvad)
- Added complete test coverage for:
  - UDP/TCP SRV clients
  - DoH SRV (multi + parallel)
  - System and public resolver detection
  - Error fallback (UDP timeout → TCP)
- Refactored project structure:

lib/src/doh/
lib/src/udp_tcp/
lib/src/models/
example/dns_client_example.dart

### ⚙️ Improvements
- Enhanced fallback logic between Google and Cloudflare DoH resolvers.
- Added English-only documentation comments for consistency.
- Improved debug logging for all SRV clients.

### 🧩 Fixes
- Better error handling for IPv6 and system DNS detection.
- Tests now handle dynamic DNS environments safely (no hardcoded IPs).
- Fixed internal method visibility and export paths.

### 🧪 Tests
- Added new unit tests for:
  - `DnsOverHttps.lookupSrvMulti()`
  - `DnsOverHttps.lookupSrvParallel()`
- Ensured 100% test coverage across DoH, UDP, and TCP clients.

### 🔧 Misc
- Updated GitHub workflows (`analyze.yml`, `test.yml`).
- Cleaned up comments and improved readability throughout the codebase.

## 0.2.1

### 🛠 Fixes
- Exported `DnsOverHttpsBinaryClient` in `super_dns_client.dart`
  so it is now publicly accessible from the package import.

### 🔧 Internal
- Minor cleanup before pub.dev publish


## 0.2.0

### ✨ New Features
- Added **DnsOverHttpsBinaryClient** for binary DNS-over-HTTPS lookups (RFC 8484).
- Support for **SRV record resolution** over DoH.
- Added **DnsResolver** object model (`name`, `url`, `supportsGet`, `isTrusted`).
- Built-in non-GAFAM resolvers:
    - Quad9
    - AdGuard
    - Yandex
    - OpenDNS
    - Mullvad (GET only)

### ⚙️ Improvements
- Automatic GET/POST selection depending on resolver capability.
- Unified `lookup()` and `lookupDataByRRType()` API with optional `resolverName`.
- Enhanced error handling for invalid resolvers and DoH failures.

### 🧪 Tests & Examples
- Added unit tests for SRV and A record lookups via Quad9.
- Updated example to demonstrate both `DnsOverHttps` and `DnsOverHttpsBinaryClient` usage.

## 0.1.0

🎉 **Initial release of `super_dns_client`**

- Added DNS-over-HTTPS client implementation
- Supported Google, Cloudflare, Quad9, and OpenDNS resolvers
- Supported record types: `A`, `AAAA`, `CNAME`, `SRV`, `TXT`
- Added base response model with `freezed` and `json_serializable`
- Unit tests and CI configuration ready
