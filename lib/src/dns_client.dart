import 'dart:io';

import 'package:super_dns_client/super_dns_client.dart';

/// Base interface for all DNS clients.
///
/// Concrete implementations may include:
/// - [SystemDnsClient] — resolves using OS-configured resolvers.
/// - [PublicDnsClient] — uses open public resolvers (Quad9, OpenDNS, AdGuard...).
/// - [DnsOverHttpsBinaryClient] — performs binary DNS-over-HTTPS lookups.
/// - [DnsOverHttps] — uses standard JSON-based DoH (Google, Cloudflare...).
/// - [CacheDnsClient] — adds in-memory caching with TTL.
///
/// Each implementation **must** provide:
/// - [lookup] — standard A/AAAA resolution
/// - [lookupDataByRRType] — record-type specific lookups (A, AAAA, TXT, etc.)
/// - [lookupSrv] — SRV record resolution (RFC 2782)
abstract class DnsClient {
  /// Whether to print debug logs.
  final bool debugMode;

  DnsClient({this.debugMode = false});

  /// Utility method for safe debug printing
  void debug(Object? message) {
    if (debugMode) {
      print(message);
    }
  }

  /// Performs a DNS lookup for A / AAAA records.
  ///
  /// Example:
  /// ```dart
  /// final client = DnsOverHttps.google();
  /// final results = await client.lookup('example.com');
  /// for (final addr in results) {
  ///   print('→ ${addr.address}');
  /// }
  /// ```
  ///
  /// Throws an [Exception] if the lookup fails.
  Future<List<InternetAddress>> lookup(
    String hostname, {
    Duration timeout = const Duration(seconds: 3),
  });

  /// Performs a DNS lookup for a specific record type (e.g. CNAME, TXT, SRV).
  ///
  /// Returns a list of raw record data (decoded strings or targets).
  /// Implementations may internally use DoH, UDP, or TCP.
  ///
  /// Example:
  /// ```dart
  /// final txtRecords = await client.lookupDataByRRType('example.com', RRType.txt);
  /// ```
  Future<List<String>> lookupDataByRRType(
    String hostname,
    RRType rrType, {
    Duration timeout = const Duration(seconds: 3),
  });

  /// Performs an SRV record lookup (RFC 2782).
  ///
  /// Example:
  /// ```dart
  /// final srvRecords = await client.lookupSrv('_jmap._tcp.linagora.com');
  /// for (final record in srvRecords) {
  ///   print('→ ${record.target}:${record.port} (prio=${record.priority}, weight=${record.weight})');
  /// }
  /// ```
  ///
  /// - [srvName]: must include the `_service._proto.domain` format.
  /// - [resolverName]: optional label (e.g. `"quad9"`, `"adguard"`) for custom resolvers.
  /// - [timeout]: max waiting time for the query.
  Future<List<SrvRecord>> lookupSrv(
    String srvName, {
    Duration timeout = const Duration(seconds: 3),
  });
}
