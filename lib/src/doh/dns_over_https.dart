import 'dart:convert';
import 'dart:io';

import 'package:super_dns_client/super_dns_client.dart';

/// DNS-over-HTTPS (DoH) client supporting multiple resolvers (Google, Cloudflare).
///
/// Provides JSON-based DoH lookups for A, AAAA, and SRV records.
/// Includes multi-resolver and parallel lookup utilities for better reliability and speed.
class DnsOverHttps extends DnsClient {
  final HttpClient _client = HttpClient();
  final String url;
  final Uri _uri;
  final bool maximalPrivacy;
  final Duration timeout;

  DnsOverHttps(
    this.url, {
    Duration? timeout,
    this.maximalPrivacy = false,
    super.debugMode,
  })  : timeout = timeout ?? const Duration(seconds: 5),
        _uri = Uri.parse(url) {
    _client.connectionTimeout = this.timeout;
  }

  /// Close the underlying HTTP client.
  void close({bool force = false}) => _client.close(force: force);

  /// Factory: Google DoH endpoint.
  factory DnsOverHttps.google({Duration? timeout, bool debugMode = false}) =>
      DnsOverHttps(
        'https://dns.google/resolve',
        timeout: timeout,
        debugMode: debugMode,
      );

  /// Factory: Cloudflare DoH endpoint.
  factory DnsOverHttps.cloudflare({
    Duration? timeout,
    bool debugMode = false,
  }) =>
      DnsOverHttps(
        'https://cloudflare-dns.com/dns-query',
        timeout: timeout,
        debugMode: debugMode,
      );

  @override
  Future<List<InternetAddress>> lookup(
    String hostname, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final record = await lookupHttps(hostname);
    final results = record.answer
            ?.where((a) => a.type == RRType.a.value)
            .map((a) => InternetAddress(a.data))
            .toList() ??
        [];
    return results;
  }

  /// Generic DoH query for A/AAAA records.
  Future<DnsRecord> lookupHttps(
    String hostname, {
    InternetAddressType type = InternetAddressType.any,
  }) async {
    final query = <String, String>{
      'name': hostname,
      'type': type == InternetAddressType.IPv6 ? 'AAAA' : 'A',
    };

    if (maximalPrivacy) query['edns_client_subnet'] = '0.0.0.0/0';

    final uri = Uri.https(_uri.authority, _uri.path, query);
    final request = await _client.getUrl(uri)
      ..headers.set(HttpHeaders.acceptHeader, 'application/dns-json');
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'DNS-over-HTTPS request failed: ${response.statusCode}',
        uri: uri,
      );
    }

    final body = await response.transform(utf8.decoder).join();
    return DnsRecord.fromJson(jsonDecode(body));
  }

  /// Generic DoH query for a specific record type (e.g., SRV, TXT, CNAME).
  Future<DnsRecord> lookupHttpsByRRType(String hostname, RRType rrType) async {
    final query = <String, String>{
      'name': hostname,
      'type': rrType.value.toString(),
    };

    if (maximalPrivacy) query['edns_client_subnet'] = '0.0.0.0/0';

    final uri = Uri.https(_uri.authority, _uri.path, query);
    final request = await _client.getUrl(uri)
      ..headers.set(HttpHeaders.acceptHeader, 'application/dns-json');
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'DNS-over-HTTPS request failed: ${response.statusCode}',
        uri: uri,
      );
    }

    final body = await response.transform(utf8.decoder).join();
    return DnsRecord.fromJson(jsonDecode(body));
  }

  @override
  Future<List<String>> lookupDataByRRType(
    String hostname,
    RRType rrType, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final record = await lookupHttpsByRRType(hostname, rrType);
    return record.answer
            ?.where((a) => a.type == rrType.value)
            .map((a) => a.data)
            .toList() ??
        [];
  }

  /// Standard SRV lookup (single resolver only).
  @override
  Future<List<SrvRecord>> lookupSrv(
    String srvName, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final record = await lookupHttpsByRRType(srvName, RRType.srv);
    return record.answer
            ?.where((a) => a.type == RRType.srv.value)
            .map(
              (a) => SrvRecord(
                name: a.name,
                target: _parseTargetFromDataResourceRecord(a.data),
                port: _parsePortFromData(a.data),
                priority: _parsePriorityFromData(a.data),
                weight: _parseWeightFromData(a.data),
                ttl: a.ttl,
              ),
            )
            .toList() ??
        [];
  }

  /// Multi-resolver SRV lookup (tries Google → Cloudflare sequentially).
  ///
  /// If Google fails or returns empty results, Cloudflare is used as fallback.
  Future<List<SrvRecord>> lookupSrvMulti(
    String srvName, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final resolvers = [
      DnsOverHttps.google(timeout: timeout),
      DnsOverHttps.cloudflare(timeout: timeout),
    ];

    for (final resolver in resolvers) {
      try {
        final record = await resolver
            .lookupHttpsByRRType(srvName, RRType.srv)
            .timeout(timeout);

        final answers =
            record.answer?.where((a) => a.type == RRType.srv.value).toList();

        if (answers != null && answers.isNotEmpty) {
          debug('[DnsOverHttps]✅ SRV record found via ${resolver.url}');

          return answers.map((a) {
            final target = _parseTargetFromDataResourceRecord(a.data);
            return SrvRecord(
              name: a.name,
              target: target,
              port: _parsePortFromData(a.data),
              priority: _parsePriorityFromData(a.data),
              weight: _parseWeightFromData(a.data),
              ttl: a.ttl,
            );
          }).toList();
        }
      } catch (e) {
        debug('[DnsOverHttps]❌ Lookup failed via ${resolver.url}: $e');
      }
    }

    throw Exception(
      '[DnsOverHttps] No SRV records found via Google or Cloudflare.',
    );
  }

  /// Parallel SRV lookup (runs Google & Cloudflare concurrently).
  ///
  /// Returns the first non-empty result to improve performance.
  Future<List<SrvRecord>> lookupSrvParallel(
    String srvName, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final resolvers = [
      DnsOverHttps.google(timeout: timeout),
      DnsOverHttps.cloudflare(timeout: timeout),
    ];

    final futures = resolvers.map((resolver) async {
      try {
        final record = await resolver
            .lookupHttpsByRRType(srvName, RRType.srv)
            .timeout(timeout);
        final answers =
            record.answer?.where((a) => a.type == RRType.srv.value).toList();

        if (answers != null && answers.isNotEmpty) {
          debug('[DnsOverHttps]✅ Parallel SRV found via ${resolver.url}');

          return answers.map((a) {
            final target = _parseTargetFromDataResourceRecord(a.data);
            return SrvRecord(
              name: a.name,
              target: target,
              port: _parsePortFromData(a.data),
              priority: _parsePriorityFromData(a.data),
              weight: _parseWeightFromData(a.data),
              ttl: a.ttl,
            );
          }).toList();
        }
      } catch (e) {
        debug('[DnsOverHttps]❌ Parallel failed via ${resolver.url}: $e');
      }
      return <SrvRecord>[];
    });

    final results = await Future.wait(futures);
    final nonEmpty = results.firstWhere(
      (list) => list.isNotEmpty,
      orElse: () => <SrvRecord>[],
    );

    if (nonEmpty.isEmpty) {
      throw Exception(
        '[DnsOverHttps] No SRV records found via Google or Cloudflare (parallel).',
      );
    }

    return nonEmpty;
  }

  // -------------------------
  // Parsing helpers
  // -------------------------

  int _parsePriorityFromData(String data) {
    final parts = data.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? int.tryParse(parts[0]) ?? -1 : -1;
  }

  int _parseWeightFromData(String data) {
    final parts = data.trim().split(RegExp(r'\s+'));
    return parts.length >= 2 ? int.tryParse(parts[1]) ?? -1 : -1;
  }

  int _parsePortFromData(String data) {
    final parts = data.trim().split(RegExp(r'\s+'));
    return parts.length >= 3 ? int.tryParse(parts[2]) ?? -1 : -1;
  }

  String _parseTargetFromDataResourceRecord(String data) {
    try {
      if (data.trim().isEmpty) return '';
      final fields = data.split(' ').where((e) => e.isNotEmpty).toList();
      if (fields.isEmpty) return '';
      final url = _removeTrailingDot(fields.last).trim();
      return url.isEmpty ? '' : url;
    } catch (_) {
      return '';
    }
  }

  String _removeTrailingDot(String value) {
    return value.endsWith('.') ? value.substring(0, value.length - 1) : value;
  }
}
