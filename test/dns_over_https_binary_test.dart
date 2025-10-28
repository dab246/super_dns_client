import 'dart:io';

import 'package:super_dns_client/src/models/srv_record.dart';
import 'package:super_dns_client/super_dns_client.dart';
import 'package:test/test.dart';

void main() {
  group('DnsOverHttpsBinaryClient (default resolvers)', () {
    test('lookup( google.com ) should return valid IPv4/IPv6 addresses',
        () async {
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
      expect(results.first, contains('SrvRecord('));
    });

    test('lookupSrv should return parsed SRV records', () async {
      final client = DnsOverHttpsBinaryClient();
      final records = await client.lookupSrv('_jmap._tcp.linagora.com');

      expect(records, isNotEmpty);
      expect(records.first.port, greaterThan(0));
      expect(records.first.target, contains('linagora'));
      expect(records.first.priority, isA<int>());
      expect(records.first.weight, isA<int>());
    });
  });

  group('DnsOverHttpsBinaryClient (custom resolver)', () {
    test('custom resolver should override default resolver list', () async {
      final custom = [
        DnsResolver(
          name: 'mullvad',
          url: Uri.parse('https://doh.mullvad.net/dns-query'),
        ),
      ];
      final client = DnsOverHttpsBinaryClient(customResolvers: custom);

      final found = client.resolvers.firstWhere((r) => r.name == 'mullvad');
      expect(found, isNotNull);
      expect(found.url.toString(), equals('https://doh.mullvad.net/dns-query'));
    });

    test('lookupSrv using only custom resolver should work or fail gracefully',
        () async {
      final custom = [
        DnsResolver(
          name: 'mullvad',
          url: Uri.parse('https://doh.mullvad.net/dns-query'),
        ),
      ];
      final client = DnsOverHttpsBinaryClient(customResolvers: custom);

      try {
        final records = await client.lookupSrv('_jmap._tcp.linagora.com');
        expect(records, isA<List<SrvRecord>>());
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('DnsOverHttpsBinaryClient (error handling)', () {
    test('should throw exception when no SRV record is found', () async {
      final client = DnsOverHttpsBinaryClient();
      expect(
        () async => await client.lookupSrv('nonexistent.domain.example'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
