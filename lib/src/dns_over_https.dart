import 'dart:convert';
import 'dart:io';

import 'package:super_dns_client/super_dns_client.dart';

/// A DNS-over-HTTPS (DoH) client implementation.
///
/// Supports Google and Cloudflare public resolvers by default, or any
/// custom resolver endpoint that implements the DoH JSON API.
class DnsOverHttps extends DnsClient {
  final HttpClient _client = HttpClient();

  /// Base URL of the DoH service (e.g., `https://dns.google/resolve`).
  final String url;

  /// Parsed URI of the DoH endpoint.
  final Uri _uri;

  /// Whether to anonymize the client IP address (EDNS client subnet).
  final bool maximalPrivacy;

  /// Timeout for DNS requests.
  final Duration timeout;

  DnsOverHttps(
    this.url, {
    Duration? timeout,
    this.maximalPrivacy = false,
  })  : timeout = timeout ?? const Duration(seconds: 5),
        _uri = Uri.parse(url) {
    _client.connectionTimeout = this.timeout;
  }

  /// Gracefully closes the underlying [HttpClient].
  void close({bool force = false}) => _client.close(force: force);

  /// Factory for Google DoH resolver.
  factory DnsOverHttps.google({Duration? timeout}) =>
      DnsOverHttps('https://dns.google/resolve', timeout: timeout);

  /// Factory for Cloudflare DoH resolver.
  factory DnsOverHttps.cloudflare({Duration? timeout}) =>
      DnsOverHttps('https://cloudflare-dns.com/dns-query', timeout: timeout);

  @override
  Future<List<InternetAddress>> lookup(String hostname) async {
    final record = await lookupHttps(hostname);
    final results = record.answer
            ?.where((a) => a.type == RRType.a.value)
            .map((a) => InternetAddress(a.data))
            .toList() ??
        [];

    return results;
  }

  /// Performs a DoH query and returns the [DnsRecord].
  Future<DnsRecord> lookupHttps(
    String hostname, {
    InternetAddressType type = InternetAddressType.any,
  }) async {
    final query = <String, String>{
      'name': hostname,
      'type': type == InternetAddressType.IPv6 ? 'AAAA' : 'A',
    };

    if (maximalPrivacy) {
      query['edns_client_subnet'] = '0.0.0.0/0';
    }

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

  /// Performs a DoH query for a specific [RRType].
  Future<DnsRecord> lookupHttpsByRRType(String hostname, RRType rrType) async {
    final query = <String, String>{
      'name': hostname,
      'type': rrType.value.toString(),
    };

    if (maximalPrivacy) {
      query['edns_client_subnet'] = '0.0.0.0/0';
    }

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
    RRType rrType,
  ) async {
    final record = await lookupHttpsByRRType(hostname, rrType);
    return record.answer
            ?.where((a) => a.type == rrType.value)
            .map((a) => a.data)
            .toList() ??
        [];
  }
}
