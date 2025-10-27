# Changelog

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
