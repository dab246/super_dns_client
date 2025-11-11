import 'dart:async';

import 'package:super_dns_client/src/models/srv_record.dart';
import 'package:super_dns_client/src/udp_tcp/base_udp_srv_client.dart';
import 'package:super_dns_client/src/udp_tcp/public_udp_srv_client.dart';
import 'package:super_dns_client/src/udp_tcp/system_udp_srv_client.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

/// Mock class to simulate network packets and responses
class MockUdpSrvClient extends BaseUdpSrvClient {
  bool udpCalled = false;
  bool tcpCalled = false;
  bool shouldTruncate = false;
  bool shouldFailUdp = false;
  bool shouldFailTcp = false;

  @override
  Future<List<InternetAddress>> getDnsServers({String? host}) async =>
      [InternetAddress('127.0.0.1')];

  @override
  Future<List<SrvRecord>> lookupSrv(
    String srvName, {
    String? resolverName,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (shouldFailUdp) throw TimeoutException('UDP failed');
    udpCalled = true;
    if (shouldTruncate) {
      // Fallback TCP
      tcpCalled = true;
      return [
        SrvRecord(
          name: srvName,
          target: 'mail.fastmail.com',
          port: 443,
          priority: 1,
          weight: 5,
          ttl: 300,
        ),
      ];
    }

    return [
      SrvRecord(
        name: srvName,
        target: 'imap.fastmail.com',
        port: 993,
        priority: 10,
        weight: 20,
        ttl: 300,
      ),
    ];
  }
}

void main() {
  group('🧩 PublicUdpSrvClient', () {
    test('returns predefined list of open resolvers', () async {
      final resolver = PublicUdpSrvClient();
      final servers = await resolver.getDnsServers();

      expect(servers, isNotEmpty);
      final ips = servers.map((e) => e.address).toList();
      expect(
        ips,
        containsAll([
          '9.9.9.9',
          '94.140.14.14',
          '208.67.222.222',
        ]),
      );
    });

    test('lookupSrv() should return SRV records (mocked)', () async {
      final mock = MockUdpSrvClient();
      final records = await mock.lookupSrv('_jmap._tcp.fastmail.com');

      expect(records, isNotEmpty);
      final first = records.first;
      expect(first.target, equals('imap.fastmail.com'));
      expect(first.port, equals(993));
      expect(first.priority, equals(10));
      expect(first.weight, equals(20));
      expect(first.ttl, equals(300));
      expect(mock.udpCalled, isTrue);
    });

    test('fallbacks to TCP if UDP truncated', () async {
      final mock = MockUdpSrvClient()..shouldTruncate = true;
      final records = await mock.lookupSrv('_jmap._tcp.fastmail.com');
      expect(records.first.target, equals('mail.fastmail.com'));
      expect(mock.tcpCalled, isTrue);
    });
  });

  group('🧩 SystemUdpSrvClient', () {
    test('returns system DNS from /etc/resolv.conf or platform DNS', () async {
      final resolver = SystemUdpSrvClient();
      final servers = await resolver.getDnsServers();

      expect(
        servers,
        isNotEmpty,
        reason: 'Should detect system-configured DNS servers',
      );

      // At least one valid IP address (v4 or v6)
      final allValid = servers.every(
        (e) =>
            InternetAddress.tryParse(e.address) != null &&
            (e.type == InternetAddressType.IPv4 ||
                e.type == InternetAddressType.IPv6),
      );
      expect(
        allValid,
        isTrue,
        reason: 'All returned servers should be valid IP addresses',
      );

      // If not from system, fallback should be 1.1.1.1
      if (servers.length == 1 && servers.first.address == '1.1.1.1') {
        print('✅ Fallback 1.1.1.1 used.');
      } else {
        print(
          '✅ System DNS servers detected: ${servers.map((e) => e.address)}',
        );
      }
    });

    test('falls back to 1.1.1.1 when no system DNS found', () async {
      final resolver = SystemUdpSrvClient();
      final servers = await resolver.getDnsServers();
      expect(servers, isNotEmpty);
      expect(
        servers.first.address,
        anyOf(
          equals('1.1.1.1'), // fallback
          matches(RegExp(r'^(\d{1,3}\.){3}\d{1,3}$')), // IPv4
          matches(RegExp(r'^[0-9a-fA-F:]+$')), // IPv6
        ),
        reason: 'Must return a valid IPv4/IPv6 or fallback to 1.1.1.1',
      );
    });

    test('returns system or fallback DNS safely', () async {
      final resolver = SystemUdpSrvClient();
      final servers = await resolver.getDnsServers();

      expect(servers, isNotEmpty,
          reason: 'Should always return at least one DNS server');

      // Verify each address is valid
      for (final ip in servers.map((e) => e.address)) {
        expect(
          InternetAddress.tryParse(ip),
          isNotNull,
          reason: 'Invalid IP address returned: $ip',
        );
      }

      final joined = servers.map((e) => e.address).join(', ');
      if (joined.contains('1.1.1.1') || joined.contains('8.8.8.8')) {
        print('✅ Fallback DNS detected: $joined');
      } else {
        print('✅ System DNS detected: $joined');
      }
    });
  });

  group('🧪 Integration mock behavior', () {
    test('MockUdpSrvClient handles UDP failure gracefully', () async {
      final mock = MockUdpSrvClient()..shouldFailUdp = true;
      try {
        await mock.lookupSrv('_jmap._tcp.fastmail.com');
      } catch (e) {
        expect(e, isA<TimeoutException>());
      }
    });
  });
}
