import 'dart:convert';

import 'package:super_dns/super_dns.dart' as super_dns;
import 'package:super_dns_client/src/udp_tcp/base_udp_srv_client.dart';
import 'package:super_raw/raw.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

class _LoopbackUdpSrvClient extends BaseUdpSrvClient {
  _LoopbackUdpSrvClient(int port)
      : super(dnsPort: port, timeout: const Duration(seconds: 1));

  @override
  Future<List<InternetAddress>> getDnsServers({String? host}) async =>
      [InternetAddress.loopbackIPv4];
}

const _srvName = '_jmap._tcp.example.com';

List<int> _srvResponse(
  super_dns.DnsPacket query, {
  int? id,
  String? questionName,
  String target = 'mail.example.com',
}) {
  final rdata = RawWriter.withCapacity(64)
    ..writeUint16(10)
    ..writeUint16(5)
    ..writeUint16(443);
  for (final label in target.split('.')) {
    rdata
      ..writeUint8(label.length)
      ..writeBytes(utf8.encode(label));
  }
  rdata.writeUint8(0);

  return (super_dns.DnsPacket()
        ..isResponse = true
        ..id = id ?? query.id
        ..questions = [
          super_dns.DnsQuestion()
            ..name = questionName ?? query.questions.single.name
            ..type = super_dns.DnsResourceRecord.typeServerDiscovery
            ..classy = super_dns.DnsResourceRecord.classInternetAddress,
        ]
        ..answers = [
          super_dns.DnsResourceRecord()
            ..name = questionName ?? query.questions.single.name
            ..type = super_dns.DnsResourceRecord.typeServerDiscovery
            ..classy = super_dns.DnsResourceRecord.classInternetAddress
            ..ttl = 300
            ..data = rdata.toUint8ListCopy(),
        ])
      .toImmutableBytes();
}

void main() {
  late RawDatagramSocket server;
  final extra = <RawDatagramSocket>[];

  setUp(() async {
    server = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() {
    server.close();
    for (final s in extra) {
      s.close();
    }
    extra.clear();
  });

  void serve(void Function(super_dns.DnsPacket query, Datagram from) reply) {
    server.listen((event) {
      if (event != RawSocketEvent.read) return;
      final d = server.receive();
      if (d == null) return;
      final query = super_dns.DnsPacket()
        ..decodeSelf(RawReader.withBytes(d.data));
      reply(query, d);
    });
  }

  test('accepts a reply matching id, source and question', () async {
    serve((q, from) => server.send(_srvResponse(q), from.address, from.port));

    final records =
        await _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName);

    expect(records.single.target, 'mail.example.com');
  });

  test('sends a well-formed SRV query for a trailing-dot name', () async {
    late super_dns.DnsPacket received;
    serve((q, from) {
      received = q;
      server.send(_srvResponse(q), from.address, from.port);
    });

    await _LoopbackUdpSrvClient(server.port).lookupSrv('$_srvName.');

    expect(
      received.questions.single.type,
      super_dns.DnsResourceRecord.typeServerDiscovery,
    );
  });

  test('ignores a wrong-id reply and waits for the matching one', () async {
    serve((q, from) {
      server
        ..send(
          _srvResponse(
            q,
            id: (q.id + 1) & 0xFFFF,
            target: 'evil.example.com',
          ),
          from.address,
          from.port,
        )
        ..send(_srvResponse(q), from.address, from.port);
    });

    final records =
        await _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName);

    expect(records.single.target, 'mail.example.com');
  });

  test('rejects a reply for a different question name', () async {
    serve((q, from) {
      server.send(
        _srvResponse(q, questionName: '_jmap._tcp.evil.com'),
        from.address,
        from.port,
      );
    });

    expect(
      _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName),
      throwsException,
    );
  });

  test('accepts a reply whose question name differs only in case', () async {
    serve((q, from) {
      server.send(
        _srvResponse(q, questionName: _srvName.toUpperCase()),
        from.address,
        from.port,
      );
    });

    final records =
        await _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName);

    expect(records.single.target, 'mail.example.com');
  });

  test('ignores replies that do not answer the SRV question', () async {
    List<int> spoofed(
      super_dns.DnsPacket q,
      void Function(super_dns.DnsPacket) edit,
    ) {
      final p = super_dns.DnsPacket()
        ..decodeSelf(
          RawReader.withBytes(_srvResponse(q, target: 'evil.example.com')),
        );
      edit(p);
      return p.toImmutableBytes();
    }

    serve((q, from) {
      for (final reply in [
        spoofed(q, (p) => p.isResponse = false),
        spoofed(q, (p) => p.questions = []),
        spoofed(q, (p) => p.questions.single.type = 1),
        spoofed(q, (p) => p.questions.single.classy = 3),
        _srvResponse(q),
      ]) {
        server.send(reply, from.address, from.port);
      }
    });

    final records =
        await _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName);

    expect(records.single.target, 'mail.example.com');
  });

  test('ignores an undecodable datagram and waits for the matching one',
      () async {
    serve((q, from) {
      server
        ..send([0xde, 0xad], from.address, from.port)
        ..send(_srvResponse(q), from.address, from.port);
    });

    final records =
        await _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName);

    expect(records.single.target, 'mail.example.com');
  });

  test(
    'fails instead of hanging on a malformed SRV answer',
    () async {
      serve((q, from) {
        final reply = super_dns.DnsPacket()
          ..decodeSelf(RawReader.withBytes(_srvResponse(q)));
        reply.answers.single.data = [0, 10];
        server.send(reply.toImmutableBytes(), from.address, from.port);
      });

      await expectLater(
        _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName),
        throwsException,
      );
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );

  test('rejects a reply from an unexpected source port', () async {
    final spoofer =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    extra.add(spoofer);
    serve((q, from) => spoofer.send(_srvResponse(q), from.address, from.port));

    expect(
      _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName),
      throwsException,
    );
  });

  group('TCP fallback', () {
    late ServerSocket tcpServer;

    setUp(() async {
      tcpServer =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, server.port);
      // Truncated UDP reply pushes the client onto TCP.
      serve((q, from) {
        final truncated = super_dns.DnsPacket()
          ..isResponse = true
          ..isTruncated = true
          ..id = q.id
          ..questions = q.questions;
        server.send(truncated.toImmutableBytes(), from.address, from.port);
      });
    });

    tearDown(() => tcpServer.close());

    void serveTcp(List<int> Function(super_dns.DnsPacket query) reply) {
      tcpServer.listen((client) {
        final buffer = <int>[];
        client.listen((chunk) {
          buffer.addAll(chunk);
          if (buffer.length < 2) return;
          final length = (buffer[0] << 8) | buffer[1];
          if (buffer.length < 2 + length) return;
          final query = super_dns.DnsPacket()
            ..decodeSelf(RawReader.withBytes(buffer.sublist(2, 2 + length)));
          final body = reply(query);
          client
            ..add([body.length >> 8, body.length & 0xFF, ...body])
            ..close();
        });
      });
    }

    test('accepts a TCP reply matching id and question', () async {
      serveTcp((q) => _srvResponse(q));

      final records =
          await _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName);

      expect(records.single.target, 'mail.example.com');
    });

    test('rejects a TCP reply with a wrong id', () async {
      serveTcp((q) => _srvResponse(q, id: (q.id + 1) & 0xFFFF));

      await expectLater(
        _LoopbackUdpSrvClient(server.port).lookupSrv(_srvName),
        throwsException,
      );
    });
  });
}
