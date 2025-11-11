import 'package:universal_io/io.dart';

import 'package:super_dns_client/super_dns_client.dart';

Future<void> main() async {
  print('🔹 Example 1: JSON-based DoH (Google)');
  final dohGoogle = DnsOverHttps.google();
  final aResponse = await dohGoogle.lookup('google.com');
  for (var address in aResponse) {
    print('DnsOverHttps.google::A → ${address.address}');
  }

  final srvGoogle = await dohGoogle.lookupDataByRRType(
    '_jmap._tcp.fastmail.com',
    RRType.srv,
  );
  for (var srv in srvGoogle) {
    print('DnsOverHttps.google::SRV → $srv');
  }

  print('\n🔹 Example 2: JSON-based DoH (Cloudflare)');
  final dohCloudflare = DnsOverHttps.cloudflare();
  final srvCloudflare = await dohCloudflare.lookupDataByRRType(
    '_jmap._tcp.fastmail.com',
    RRType.srv,
  );
  for (var srv in srvCloudflare) {
    print('DnsOverHttps.cloudflare::SRV → $srv');
  }

  print('\n🔹 Example 3: Binary DoH client (Quad9, AdGuard, Yandex, etc.)');
  final binaryClient = DnsOverHttpsBinaryClient(debugMode: true);

  final aRecords = await binaryClient.lookup('google.com');
  for (var ip in aRecords) {
    print('DnsOverHttpsBinary::A → ${ip.address}');
  }

  final srvRecords = await binaryClient.lookupSrv('_jmap._tcp.fastmail.com');
  for (var record in srvRecords) {
    print(
      'DnsOverHttpsBinary::SRV → priority=${record.priority}, '
      'weight=${record.weight}, port=${record.port}, target=${record.target}',
    );
  }

  print('\n🔹 Example 4: Custom DoH Resolver (Mullvad only)');
  final customResolvers = [
    DnsResolver(
      name: 'mullvad',
      url: Uri.parse('https://doh.mullvad.net/dns-query'),
    ),
  ];
  final binaryCustom = DnsOverHttpsBinaryClient(
    customResolvers: customResolvers,
    debugMode: true,
  );

  try {
    final customSrvRecords =
        await binaryCustom.lookupSrv('_jmap._tcp.fastmail.com');
    for (var record in customSrvRecords) {
      print(
        'DnsOverHttpsBinary(mullvad)::SRV → '
        'priority=${record.priority}, weight=${record.weight}, '
        'port=${record.port}, target=${record.target}',
      );
    }
  } catch (e) {
    print('❌ Mullvad lookup failed: $e');
  }

  print('\n🔹 Example 5: Error handling');
  try {
    // Tên resolver không còn cần thiết — gọi sai sẽ tự động duyệt tất cả.
    await binaryClient.lookupSrv('fastmail.com');
  } on SocketException catch (e) {
    print('❌ Network error: $e');
  } on Exception catch (e) {
    print('❌ Lookup error: $e');
  }

  // 🔹 Example 6: System-configured DNS SRV Lookup
  print('\n🔹 Example 6: System-configured DNS SRV Lookup');
  final systemResolver = SystemUdpSrvClient();
  final systemRecords =
      await systemResolver.lookupSrv('_jmap._tcp.fastmail.com');

  if (systemRecords.isEmpty) {
    print('SystemUdpSrvClient: No SRV records found.');
  } else {
    print('SystemUdpSrvClient: Resolved SRV records (RFC 2782 order):');
    for (final r in systemRecords) {
      print(
        ' → ${r.target}:${r.port} '
        '(priority=${r.priority}, weight=${r.weight}, ttl=${r.ttl})',
      );
    }
  }

  // 🔹 Example 7: Public (Open) DNS SRV Lookup
  print('\n🔹 Example 7: Public (Open) DNS SRV Lookup');
  final publicResolver = PublicUdpSrvClient();
  final publicResults =
      await publicResolver.lookupSrv('_jmap._tcp.fastmail.com');

  if (publicResults.isEmpty) {
    print('PublicUdpSrvClient: No SRV records found.');
  } else {
    print('PublicUdpSrvClient: Resolved SRV records (RFC 2782 order):');
    for (final r in publicResults) {
      print(
        ' → ${r.target}:${r.port} (prio=${r.priority}, weight=${r.weight})',
      );
    }
  }

  print('\n✅ All examples completed successfully.\n');
}
