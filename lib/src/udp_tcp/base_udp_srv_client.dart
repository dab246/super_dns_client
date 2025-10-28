import 'dart:async';
import 'dart:io';

import 'package:super_dns/super_dns.dart' as super_dns;
import 'package:super_dns_client/src/models/srv_record.dart';
import 'package:super_raw/raw.dart';

import '../../super_dns_client.dart' show DnsClient, RRType;

/// Base class for all SRV resolvers (System, Public, etc.)
///
/// Provides shared UDP/TCP logic, packet parsing, and fallback behavior.
/// Subclasses only need to implement [getDnsServers].
abstract class BaseUdpSrvClient extends DnsClient {
  BaseUdpSrvClient({super.debugMode});

  /// Returns the list of DNS servers to query.
  Future<List<InternetAddress>> getDnsServers();

  /// Perform SRV lookup using UDP first, then fallback to TCP if needed.
  @override
  Future<List<SrvRecord>> lookupSrv(
    String srvName, {
    String? resolverName,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final dnsServers = await getDnsServers();
    if (dnsServers.isEmpty) {
      debug('[BaseSrvResolver] ⚠️ No DNS servers configured.');
      return [];
    }

    debug(
      '[BaseSrvResolver] 🌐 Querying $srvName via ${dnsServers.length} servers...',
    );
    final results = await Future.any(
      dnsServers.map((dns) async {
        try {
          final udp = await _lookupSrvOverUdp(srvName, dns, timeout);
          if (udp.isNotEmpty) {
            debug('[BaseSrvResolver] ✅ ${dns.address} responded via UDP');
            return udp;
          }
        } catch (e) {
          debug('[BaseSrvResolver] ⚠️ UDP failed at ${dns.address}: $e');
        }

        try {
          final tcp = await _lookupSrvOverTcp(srvName, dns, timeout);
          if (tcp.isNotEmpty) {
            debug('[BaseSrvResolver] ✅ ${dns.address} responded via TCP');
            return tcp;
          }
        } catch (e) {
          debug('[BaseSrvResolver] ❌ TCP failed at ${dns.address}: $e');
        }

        return <SrvRecord>[];
      }),
    );

    if (results.isEmpty) {
      debug('[BaseSrvResolver] ❌ No SRV records found for $srvName');
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // Internal shared UDP/TCP logic
  // ---------------------------------------------------------------------------

  Future<List<SrvRecord>> _lookupSrvOverUdp(
    String srvName,
    InternetAddress dnsServer,
    Duration timeout,
  ) async {
    final packet = super_dns.DnsPacket()
      ..id = DateTime.now().millisecondsSinceEpoch & 0xFFFF
      ..isRecursionDesired = true
      ..questions = [
        super_dns.DnsQuestion()
          ..name = srvName
          ..type = super_dns.DnsResourceRecord.typeServerDiscovery
          ..classy = super_dns.DnsResourceRecord.classInternetAddress,
      ];

    final socket = await RawDatagramSocket.bind(
      dnsServer.type == InternetAddressType.IPv6
          ? InternetAddress.anyIPv6
          : InternetAddress.anyIPv4,
      0,
    );
    socket.send(packet.toImmutableBytes(), dnsServer, 53);

    final completer = Completer<List<SrvRecord>>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('UDP timeout'));
        socket.close();
      }
    });

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram == null) return;

        try {
          final response = super_dns.DnsPacket()
            ..decodeSelf(RawReader.withBytes(datagram.data));
          if (response.isTruncated) {
            completer.complete([]);
          } else {
            completer.complete(_parseSrvAnswers(response));
          }
        } catch (e) {
          completer.completeError(e);
        } finally {
          socket.close();
          timer.cancel();
        }
      }
    });

    return completer.future;
  }

  Future<List<SrvRecord>> _lookupSrvOverTcp(
    String srvName,
    InternetAddress dnsServer,
    Duration timeout,
  ) async {
    final packet = super_dns.DnsPacket()
      ..id = DateTime.now().millisecondsSinceEpoch & 0xFFFF
      ..isRecursionDesired = true
      ..questions = [
        super_dns.DnsQuestion()
          ..name = srvName
          ..type = super_dns.DnsResourceRecord.typeServerDiscovery
          ..classy = super_dns.DnsResourceRecord.classInternetAddress,
      ];

    final bytes = packet.toImmutableBytes();
    final socket = await Socket.connect(dnsServer, 53).timeout(timeout);
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

    return completer.future.timeout(timeout);
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
  Future<List<InternetAddress>> lookup(
    String hostname, {
    Duration timeout = const Duration(seconds: 3),
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> lookupDataByRRType(
    String hostname,
    RRType rrType, {
    Duration timeout = const Duration(seconds: 3),
  }) {
    throw UnimplementedError();
  }
}
