import 'package:super_dns_client/super_dns_client.dart';
import 'package:test/test.dart';

void main() {
  group('HttpDnsClient Google', () {
    test('lookup( google.com )', () async {
      final client = DnsOverHttps.google();
      final address = await client.lookup('google.com');
      expect(address, isNotNull);
      expect(address.isNotEmpty, isTrue);
    });
  });

  group('HttpDnsClient Cloudflare', () {
    test('lookup( google.com )', () async {
      final client = DnsOverHttps.cloudflare();
      final address = await client.lookup('google.com');
      expect(address, isNotNull);
      expect(address.isNotEmpty, isTrue);
    });

    test('cname test', () async {
      final client = DnsOverHttps.cloudflare();
      final address = await client.lookup('api.google.com');
      expect(address, isNotNull);
      expect(address.isNotEmpty, isTrue);
    });

    test('close', () async {
      final client = DnsOverHttps.cloudflare();
      client.close();
      expect(client.lookup('api.google.com'), throwsA(isA<StateError>()));
    });
  });

  group('HttpDnsClient SRV lookups', () {
    test('lookupSrvMulti() should resolve via Google or Cloudflare', () async {
      final client = DnsOverHttps.google(debugMode: true);
      final records = await client.lookupSrvMulti('_jmap._tcp.linagora.com');

      expect(records, isNotNull);
      expect(records.isNotEmpty, isTrue);
      expect(records.first.target, contains('linagora'));
      expect(records.first.port, greaterThan(0));
    });

    test('lookupSrvParallel() should return first successful result', () async {
      final client = DnsOverHttps.google(debugMode: true);
      final records = await client.lookupSrvParallel('_jmap._tcp.linagora.com');

      expect(records, isNotNull);
      expect(records.isNotEmpty, isTrue);
      expect(records.first.target, contains('linagora'));
      expect(records.first.priority, isA<int>());
      expect(records.first.weight, isA<int>());
    });

    test('lookupSrv() should still work with single resolver', () async {
      final client = DnsOverHttps.google(debugMode: true);
      final records = await client.lookupSrv('_jmap._tcp.linagora.com');

      expect(records, isNotNull);
      expect(records, isA<List<SrvRecord>>());
    });
  });

  group('HttpDnsClient Error handling', () {
    test('lookupSrvMulti() should throw if SRV record not found', () async {
      final client = DnsOverHttps.google();
      expect(
        () async =>
            await client.lookupSrvMulti('_invalid._tcp.example.invalid'),
        throwsA(isA<Exception>()),
      );
    });

    test('lookupSrvParallel() should throw if both resolvers fail', () async {
      final client = DnsOverHttps.google();
      expect(
        () async =>
            await client.lookupSrvParallel('_invalid._tcp.example.invalid'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
