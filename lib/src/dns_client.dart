import 'dart:io';

import 'package:super_dns_client/super_dns_client.dart';

/// Abstract base class for DNS clients.
///
/// Implementations may include:
/// - [SystemDnsClient] using `InternetAddress.lookup()`
/// - [DoHDnsClient] using DNS-over-HTTPS resolvers
/// - [CacheDnsClient] for cached lookups
///
/// Each client must implement both standard and RR-type-specific lookups.
abstract class DnsClient {
  /// Performs a basic DNS lookup for the given [hostname].
  ///
  /// Returns a list of [InternetAddress] objects (IPv4 or IPv6).
  /// Throws an [Exception] if the lookup fails.
  Future<List<InternetAddress>> lookup(String hostname);

  /// Performs a DNS lookup for a specific [RRType].
  ///
  /// Returns a list of record data strings (e.g., IP addresses, CNAME targets, TXT values).
  /// Throws an [Exception] if the query fails or the record type is not supported.
  Future<List<String>> lookupDataByRRType(String hostname, RRType rrType);
}
