import 'dart:io';

import 'package:super_dns_client/src/dns_over_https_binary.dart';
import 'package:super_dns_client/src/dns_resolver.dart';
import 'package:super_dns_client/super_dns_client.dart';
import 'package:test/test.dart';

void main() {
  group('DnsOverHttpsBinaryClient Quad9', () {
    test('lookup( google.com )', () async {
      final client = DnsOverHttpsBinaryClient();
      final addresses = await client.lookup('google.com');

      expect(addresses, isNotNull);
      expect(addresses.isNotEmpty, isTrue);
      expect(addresses.first, isA<InternetAddress>());
      expect(addresses.first.address, contains('.'));
    });

    test('lookupDataByRRType SRV ( _jmap._tcp.linagora.com )', () async {
      final client = DnsOverHttpsBinaryClient();
      final results = await client.lookupDataByRRType(
        '_jmap._tcp.linagora.com',
        RRType.srv,
      );

      expect(results, isNotNull);
      expect(results.isNotEmpty, isTrue);
      expect(results.first, contains('SRV('));
    });

    test('lookupSrv should return parsed SRV objects', () async {
      final client = DnsOverHttpsBinaryClient();
      final records = await client.lookupSrv(domain: '_jmap._tcp.linagora.com');

      expect(records, isNotEmpty);
      expect(records.first.port, greaterThan(0));
      expect(records.first.target, contains('linagora'));
      expect(records.first.priority, isA<int>());
      expect(records.first.weight, isA<int>());
    });
  });

  group('DnsOverHttpsBinaryClient custom resolver', () {
    test('custom resolver should override default', () async {
      final custom = [
        DnsResolver(
          name: 'mullvad',
          url: Uri.parse('https://doh.mullvad.net/dns-query'),
        ),
      ];
      final client = DnsOverHttpsBinaryClient(customResolvers: custom);

      expect(
        client.resolvers.firstWhere((r) => r.name == 'mullvad'),
        isNotNull,
      );
      expect(
        client.resolvers.firstWhere((r) => r.name == 'mullvad').url.toString(),
        equals('https://doh.mullvad.net/dns-query'),
      );
    });
  });

  group('DnsOverHttpsBinaryClient invalid resolver', () {
    test('should throw error for unknown resolver', () async {
      final client = DnsOverHttpsBinaryClient();
      expect(
        () => client.lookupSrv(domain: 'example.com', resolverName: 'invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
