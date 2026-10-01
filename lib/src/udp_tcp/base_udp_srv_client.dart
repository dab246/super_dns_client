import 'dart:async';
import 'dart:math';

import 'package:super_dns/super_dns.dart' as super_dns;
import 'package:super_dns_client/src/models/srv_record.dart';
import 'package:super_raw/raw.dart';
import 'package:universal_io/io.dart';

import '../../super_dns_client.dart' show DnsClient, RRType;

/// Base class for all SRV resolvers (System, Public, etc.)
///
/// Provides shared UDP/TCP logic, packet parsing, and fallback behavior.
/// Subclasses only need to implement [getDnsServers].
abstract class BaseUdpSrvClient extends DnsClient {
  BaseUdpSrvClient({super.debugMode, super.timeout, this.dnsPort = 53});

  /// DNS server port; overridable for tests.
  final int dnsPort;

  static final Random _txIdRandom = Random.secure();

  /// Returns the list of DNS servers to query.
  Future<List<InternetAddress>> getDnsServers({String? host});

  /// Perform SRV lookup using UDP first, then fallback to TCP if needed.
  @override
  Future<List<SrvRecord>> lookupSrv(
    String srvName, {
    String? resolverName,
  }) async {
    final dnsServers = await getDnsServers(host: srvName);
    if (dnsServers.isEmpty) {
      debug('[BaseUdpSrvClient] ⚠️ No DNS servers configured.');
      throw Exception('No DNS servers configured.');
    }

    debug(
      '[BaseUdpSrvClient] 🌐 Querying $srvName via ${dnsServers.length} servers...',
    );

    for (final dns in dnsServers) {
      try {
        final udp = await _lookupSrvOverUdp(srvName, dns, timeout: timeout);
        if (udp.isNotEmpty) {
          debug('[BaseUdpSrvClient] ✅ ${dns.address} responded via UDP');
          return udp;
        } else {
          debug(
            '[BaseUdpSrvClient]⚠️ No SRV record found from ${dns.address} via UDP',
          );
        }
      } catch (e) {
        debug('[BaseUdpSrvClient] ❌️ UDP failed at ${dns.address}: $e');
      }

      try {
        final tcp = await _lookupSrvOverTcp(srvName, dns, timeout: timeout);
        if (tcp.isNotEmpty) {
          debug('[BaseUdpSrvClient] ✅ ${dns.address} responded via TCP');
          return tcp;
        } else {
          debug(
            '[BaseUdpSrvClient]⚠️ No SRV record found from ${dns.address} via TCP',
          );
        }
      } catch (e) {
        debug('[BaseUdpSrvClient] ❌ TCP failed at ${dns.address}: $e');
      }
    }

    debug('[BaseUdpSrvClient] ⚠️ No SRV records found for $srvName');
    throw Exception('No SRV records found for $srvName');
  }

  // ---------------------------------------------------------------------------
  // Internal shared UDP/TCP logic
  // ---------------------------------------------------------------------------

  super_dns.DnsPacket _buildSrvQuery(String srvName) => super_dns.DnsPacket()
    ..id = _txIdRandom.nextInt(0x10000)
    ..isRecursionDesired = true
    ..questions = [
      super_dns.DnsQuestion()
        ..name = _stripTrailingDot(srvName)
        ..type = super_dns.DnsResourceRecord.typeServerDiscovery
        ..classy = super_dns.DnsResourceRecord.classInternetAddress,
    ];

  // Reject answers not tied to our query (spoofed or stray datagrams).
  bool _matchesQuery(super_dns.DnsPacket response, super_dns.DnsPacket query) {
    if (!response.isResponse || response.id != query.id) return false;
    if (response.questions.length != 1) return false;
    final asked = query.questions.single;
    final answered = response.questions.single;
    return _normalizeName(answered.name) == _normalizeName(asked.name) &&
        answered.type == asked.type &&
        answered.classy == asked.classy;
  }

  String _normalizeName(String name) => _stripTrailingDot(name.toLowerCase());

  String _stripTrailingDot(String name) =>
      name.endsWith('.') ? name.substring(0, name.length - 1) : name;

  Future<List<SrvRecord>> _lookupSrvOverUdp(
    String srvName,
    InternetAddress dnsServer, {
    Duration? timeout,
  }) async {
    final packet = _buildSrvQuery(srvName);

    final socket = await RawDatagramSocket.bind(
      dnsServer.type == InternetAddressType.IPv6
          ? InternetAddress.anyIPv6
          : InternetAddress.anyIPv4,
      0,
    );
    socket.send(packet.toImmutableBytes(), dnsServer, dnsPort);

    final completer = Completer<List<SrvRecord>>();

    final Timer? timer = timeout != null
        ? Timer(timeout, () {
            if (!completer.isCompleted) {
              completer.completeError(TimeoutException('UDP timeout'));
              socket.close();
            }
          })
        : null;

    socket.listen((event) {
      if (event != RawSocketEvent.read || completer.isCompleted) return;
      final datagram = socket.receive();
      if (datagram == null) return;
      if (datagram.address != dnsServer || datagram.port != dnsPort) return;

      final super_dns.DnsPacket response;
      try {
        response = super_dns.DnsPacket()
          ..decodeSelf(RawReader.withBytes(datagram.data));
      } catch (_) {
        return;
      }
      if (!_matchesQuery(response, packet)) return;

      try {
        completer.complete(
          response.isTruncated ? <SrvRecord>[] : _parseSrvAnswers(response),
        );
      } catch (e) {
        completer.completeError(e);
      } finally {
        socket.close();
        timer?.cancel();
      }
    });

    return completer.future;
  }

  Future<List<SrvRecord>> _lookupSrvOverTcp(
    String srvName,
    InternetAddress dnsServer, {
    Duration? timeout,
  }) async {
    final packet = _buildSrvQuery(srvName);

    final bytes = packet.toImmutableBytes();
    final socket = await Socket.connect(dnsServer, dnsPort, timeout: timeout);
    final writer = RawWriter.withCapacity(bytes.length + 2)
      ..writeUint16(bytes.length)
      ..writeBytes(bytes);
    socket.add(writer.toUint8ListView());

    final completer = Completer<List<SrvRecord>>();
    final buffer = <int>[];

    socket.listen(
      (chunk) => buffer.addAll(chunk),
      onDone: () {
        try {
          if (buffer.length < 2) throw Exception('TCP response too short');
          final reader = RawReader.withBytes(buffer);
          final length = reader.readUint16();
          final dnsResponse = super_dns.DnsPacket()
            ..decodeSelf(reader.readRawReader(length));
          if (!_matchesQuery(dnsResponse, packet)) {
            throw Exception('DNS response does not match query');
          }
          completer.complete(_parseSrvAnswers(dnsResponse));
        } catch (e) {
          completer.completeError(e);
        } finally {
          socket.destroy();
        }
      },
      onError: (e) {
        completer.completeError(e);
        socket.destroy();
      },
    );

    if (timeout != null) {
      return completer.future.timeout(timeout);
    } else {
      return completer.future;
    }
  }

  // ---------------------------------------------------------------------------
  // Shared SRV parsing logic
  // ---------------------------------------------------------------------------

  List<SrvRecord> _parseSrvAnswers(super_dns.DnsPacket response) {
    final srvAnswers = response.answers
        .where((a) => a.type == super_dns.DnsResourceRecord.typeServerDiscovery)
        .toList();

    return [
      for (final record in srvAnswers) _decodeSrvRecord(record),
    ];
  }

  SrvRecord _decodeSrvRecord(super_dns.DnsResourceRecord record) {
    final reader = RawReader.withBytes(record.data);
    final priority = reader.readUint16();
    final weight = reader.readUint16();
    final port = reader.readUint16();
    final target = _readDnsName(reader, 0).join('.');

    return SrvRecord(
      name: record.name,
      target: target,
      port: port,
      priority: priority,
      weight: weight,
      ttl: record.ttl,
    );
  }

  List<String> _readDnsName(RawReader reader, int startIndex) {
    final parts = <String>[];
    while (reader.availableLengthInBytes > 0) {
      final len = reader.readUint8();
      if (len == 0) break;
      if (len < 64) {
        parts.add(reader.readUtf8(len));
      } else {
        final offset = ((len & 0x3F) << 8) | reader.readUint8();
        final old = reader.index;
        reader.index = startIndex + offset;
        parts.addAll(_readDnsName(reader, startIndex));
        reader.index = old;
        break;
      }
    }
    return parts;
  }

  @override
  Future<List<InternetAddress>> lookup(String hostname) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> lookupDataByRRType(String hostname, RRType rrType) {
    throw UnimplementedError();
  }
}
