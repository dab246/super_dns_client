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
}
