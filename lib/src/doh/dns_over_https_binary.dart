import 'dart:convert';
import 'dart:typed_data';

import 'package:super_dns_client/super_dns_client.dart';
import 'package:universal_io/io.dart';

class DnsOverHttpsBinaryClient extends DnsClient {
  final HttpClient _httpClient = HttpClient();

  static final List<DnsResolver> defaultResolvers = [
    DnsResolver(
      name: 'quad9',
      url: Uri.parse('https://dns.quad9.net/dns-query'),
    ),
    DnsResolver(
      name: 'adguard',
      url: Uri.parse('https://dns.adguard-dns.com/dns-query'),
    ),
    DnsResolver(
      name: 'yandex',
      url: Uri.parse('https://dns.yandex.com/dns-query'),
    ),
    DnsResolver(
      name: 'opendns',
      url: Uri.parse('https://doh.opendns.com/dns-query'),
    ),
    DnsResolver(
      name: 'mullvad',
      url: Uri.parse('https://doh.mullvad.net/dns-query'),
      supportsGet: true, // Mullvad only support GET
    ),
  ];

  final List<DnsResolver> resolvers;
  final Duration timeout;

  DnsOverHttpsBinaryClient({
    List<DnsResolver>? customResolvers,
    Duration? timeout,
    super.debugMode,
  })  : timeout = timeout ?? const Duration(seconds: 5),
        resolvers = [...defaultResolvers, ...?customResolvers] {
    _httpClient.connectionTimeout = this.timeout;
  }

  @override
  Future<List<InternetAddress>> lookup(
    String hostname, {
    String resolverName = 'quad9',
  }) async {
    final resolver = _getResolver(resolverName);
    final queryBytes = _buildDnsQuery(hostname, RRType.a);
    final useGet = _resolverRequiresGet(resolver.url);
    final responseBytes = await _sendDoH(
      resolver.url,
      queryBytes,
      useGet: useGet,
    );
    return _parseARecords(responseBytes)
        .map((ip) => InternetAddress(ip))
        .toList();
  }

  @override
  Future<List<String>> lookupDataByRRType(
    String hostname,
    RRType rrType, {
    String resolverName = 'quad9',
  }) async {
    final resolver = _getResolver(resolverName);
    final queryBytes = _buildDnsQuery(hostname, rrType);
    final useGet = _resolverRequiresGet(resolver.url);
    final responseBytes = await _sendDoH(
      resolver.url,
      queryBytes,
      useGet: useGet,
    );

    if (rrType == RRType.srv) {
      return _parseSrvRecords(responseBytes).map((r) => r.toString()).toList();
    } else if (rrType == RRType.a) {
      return _parseARecords(responseBytes);
    }

    throw UnimplementedError('RRType ${rrType.name} not yet supported');
  }

  @override
  Future<List<SrvRecord>> lookupSrv(String srvName) async {
    final queryBytes = _buildDnsQuery(srvName, RRType.srv);

    for (final resolver in resolvers) {
      try {
        final useGet = _resolverRequiresGet(resolver.url);
        final responseBytes = await _sendDoH(
          resolver.url,
          queryBytes,
          useGet: useGet,
        );

        final records = _parseSrvRecords(responseBytes);
        if (records.isNotEmpty) {
          debug(
            '[DnsOverHttpsBinaryClient]✅ SRV record found using ${resolver.name}: ${records.first.target}:${records.first.port}',
          );
          return records;
        } else {
          debug(
            '[DnsOverHttpsBinaryClient]⚠️ No SRV record found from ${resolver.name}',
          );
        }
      } catch (e) {
        debug(
          '[DnsOverHttpsBinaryClient]❌ Failed SRV lookup via ${resolver.name}: $e',
        );
      }
    }

    throw Exception(
      '[DnsOverHttpsBinaryClient] No SRV records found from any resolver',
    );
  }

  DnsResolver _getResolver(String name) {
    return resolvers.firstWhere(
      (r) => r.name == name,
      orElse: () => throw ArgumentError('Unknown resolver: $name'),
    );
  }

  bool _resolverRequiresGet(Uri resolver) {
    final host = resolver.host.toLowerCase();
    return host.contains('mullvad') || host.contains('nextdns');
  }

  Future<Uint8List> _sendDoH(
    Uri resolver,
    Uint8List queryBytes, {
    bool useGet = false,
  }) async {
    if (useGet) {
      final encoded = base64Url.encode(queryBytes).replaceAll('=', '');
      final url = Uri.parse('${resolver.toString()}?dns=$encoded');
      final request = await _httpClient.getUrl(url);
      request.headers.add('accept', 'application/dns-message');
      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'DoH query failed: ${response.statusCode}',
          uri: url,
        );
      }

      final buffer = BytesBuilder();
      await for (final chunk in response) {
        buffer.add(chunk);
      }
      return buffer.toBytes();
    } else {
      final request = await _httpClient.postUrl(resolver);
      request.headers.contentType = ContentType('application', 'dns-message');
      request.headers.add('accept', 'application/dns-message');
      request.add(queryBytes);

      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException(
          'DoH query failed: ${response.statusCode}',
          uri: resolver,
        );
      }

      final buffer = BytesBuilder();
      await for (final chunk in response) {
        buffer.add(chunk);
      }
      return buffer.toBytes();
    }
  }

  Uint8List _buildDnsQuery(String domain, RRType type) {
    final id = 0x1234;
    final flags = 0x0100;
    final header = ByteData(12)
      ..setUint16(0, id)
      ..setUint16(2, flags)
      ..setUint16(4, 1)
      ..setUint16(6, 0)
      ..setUint16(8, 0)
      ..setUint16(10, 0);

    final name = _encodeDomain(domain);
    final question = ByteData(4)
      ..setUint16(0, type.value)
      ..setUint16(2, 1);

    final bytes = BytesBuilder()
      ..add(header.buffer.asUint8List())
      ..add(name)
      ..add(question.buffer.asUint8List());
    return bytes.toBytes();
  }

  Uint8List _encodeDomain(String domain) {
    final parts = domain.split('.');
    final bytes = BytesBuilder();
    for (final p in parts) {
      bytes.add([p.length]);
      bytes.add(utf8.encode(p));
    }
    bytes.add([0]);
    return bytes.toBytes();
  }

  List<SrvRecord> _parseSrvRecords(Uint8List dataBytes) {
    final data = ByteData.sublistView(dataBytes);
    int offset = 12;

    while (dataBytes[offset] != 0) {
      offset += dataBytes[offset] + 1;
    }
    offset += 1 + 4;

    final results = <SrvRecord>[];

    while (offset < data.lengthInBytes) {
      if (dataBytes[offset] & 0xC0 == 0xC0) {
        offset += 2;
      } else {
        while (dataBytes[offset] != 0) {
          offset += dataBytes[offset] + 1;
        }
        offset += 1;
      }

      if (offset + 10 > data.lengthInBytes) break;

      final type = data.getUint16(offset);
      final rrClass = data.getUint16(offset + 2);
      final ttl = data.getUint32(offset + 4);
      final rdLength = data.getUint16(offset + 8);
      offset += 10;

      if (type == 33 &&
          rrClass == 1 &&
          offset + rdLength <= data.lengthInBytes) {
        final priority = data.getUint16(offset);
        final weight = data.getUint16(offset + 2);
        final port = data.getUint16(offset + 4);

        final labels = _readDomain(dataBytes, offset + 6);
        results.add(
          SrvRecord(
            priority: priority,
            weight: weight,
            port: port,
            target: labels.join('.'),
            ttl: ttl,
            name: 'SRV',
          ),
        );
      }

      offset += rdLength;
    }

    return results;
  }

  List<String> _parseARecords(Uint8List dataBytes) {
    final data = ByteData.sublistView(dataBytes);
    int offset = 12;

    while (dataBytes[offset] != 0) {
      offset += dataBytes[offset] + 1;
    }
    offset += 1 + 4;

    final results = <String>[];

    while (offset < data.lengthInBytes) {
      if (dataBytes[offset] & 0xC0 == 0xC0) {
        offset += 2;
      } else {
        while (dataBytes[offset] != 0) {
          offset += dataBytes[offset] + 1;
        }
        offset += 1;
      }

      if (offset + 10 > data.lengthInBytes) break;

      final type = data.getUint16(offset);
      final rrClass = data.getUint16(offset + 2);
      final rdLength = data.getUint16(offset + 8);
      offset += 10;

      if (type == 1 && rrClass == 1 && rdLength == 4) {
        final ipBytes = dataBytes.sublist(offset, offset + 4);
        final ip = ipBytes.join('.');
        results.add(ip);
      }

      offset += rdLength;
    }

    return results;
  }

  List<String> _readDomain(Uint8List bytes, int offset) {
    final labels = <String>[];
    while (offset < bytes.length) {
      final len = bytes[offset];
      if (len == 0) break;
      if (len & 0xC0 == 0xC0) {
        final ptr = ((len & 0x3F) << 8) | bytes[offset + 1];
        labels.addAll(_readDomain(bytes, ptr));
        break;
      } else {
        labels.add(utf8.decode(bytes.sublist(offset + 1, offset + 1 + len)));
        offset += len + 1;
      }
    }
    return labels;
  }
}
