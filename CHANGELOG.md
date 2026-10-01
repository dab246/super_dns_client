# Changelog

## 0.3.10
### Fixed

- **SRV lookups over UDP/TCP could accept a spoofed reply.** `BaseUdpSrvClient` (used by `SystemUdpSrvClient` and `PublicUdpSrvClient`) now uses a random transaction id from `Random.secure()` instead of the clock.
- UDP replies are ignored unless they come from the queried server's address and port, decode as DNS, and match the query's id, question name (case-insensitive), type and class. If no matching reply arrives, the lookup times out as before.
- A TCP reply that does not match the query now fails the lookup.
- SRV names with a trailing dot (`_xmpp-client._tcp.jabber.org.`) now resolve. The trailing dot used to produce a malformed query that returned no records.

### Added

- `dnsPort` constructor parameter on `BaseUdpSrvClient` (default `53`).

## 0.3.9
### Fixed

- **`DnsOverHttpsBinaryClient` default resolver** changed from Quad9 to AdGuard. Quad9 now requires HTTP/2, which `HttpClient` does not support, so `lookup()` and `lookupDataByRRType()` failed with the default settings.
- Removed Quad9, Mullvad (HTTP/2 only) and Yandex (redirects to a captcha page) from `DnsOverHttpsBinaryClient.defaultResolvers`.
- DoH POST requests now send `Content-Length` instead of a chunked body, which OpenDNS rejected with HTTP 400.

## 0.3.8
### Fixed

- **Fixed InternetAddress type mismatch** when building for Web by unifying imports through `package:universal_io/io.dart`.
- Ensured consistent `Future<List<InternetAddress>>` return type across all platforms.

## 0.3.7
### ✨ New Features
- **Native system DNS integration** for Android and iOS:
  - Android now retrieves DNS servers directly from `ConnectivityManager.getLinkProperties()`.
  - iOS uses BSD resolver API (`res_ninit`) to enumerate system DNS servers.
  - This provides more accurate results than previous fallback-based detection.

### 🔧 Refactor
- Updated `SystemUdpSrvClient` to use unified `PlatformSystemDns` bridge (via MethodChannel).
- Removed old `getprop` and `InternetAddress.lookup()` fallback logic.
- Restricted debug logs to debug mode (`assert()` only).
- Retained `/etc/resolv.conf` parsing for macOS and Linux.

### 🧩 Example
- Added a full **example app** for testing DNS resolution across Android, iOS, and Web.
- Example includes native verification of system DNS.

### 📝 Documentation
- Updated `README.md` with detailed explanation of native system DNS detection:
  - Android → `ConnectivityManager`
  - iOS → `res_ninit`
  - Linux/macOS → `/etc/resolv.conf`
  - Web → not supported (use DoH)
- Added platform-specific behavior table for clarity.

### 🧪 Tests
- Stabilized `SystemUdpSrvClient` tests to be cross-platform safe.
- Ensured CI-friendly fallback for headless environments.

## 0.3.6
### 🛠️ Changed

Set a default `timeout` value for the DNS client to improve request reliability.

## 0.3.5
### 🛠 Fixed
- Fixed **System DNS resolution** behavior on **Android** and **iOS**.  
  Since mobile platforms do not expose system DNS servers (`getprop` or `/etc/resolv.conf` inaccessible in sandbox),  
  the resolver now **falls back to the platform’s default DNS resolver** automatically.
- Updated `SystemUdpSrvClient` to:
  - Remove unsupported system calls on Android/iOS.
  - Use platform-resolved `InternetAddress.lookup()` instead.
  - Keep `/etc/resolv.conf` parsing for Linux/macOS environments.

### ⚙️ Internal
- Improved debug logs to clearly indicate when the client uses automatic platform DNS fallback.
- Ensured consistent behavior across Android, iOS, Linux, and macOS.

## 0.3.4
### Changed

- Replaced parallel SRV lookup with sequential lookup in DnsOverHttps to improve stability and resolver consistency.
- Ensured predictable fallback order between Google and Cloudflare resolvers.
- Minor code refactor for clarity and better logging around sequential resolution.

## 0.3.3
### Changed
- Updated dependency to `super_dns >=0.1.1` to support Flutter Web builds.
- Synchronized internal client implementation with stubbed DnsServer logic for web environments.

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
