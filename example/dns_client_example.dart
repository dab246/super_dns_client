import 'dart:io';

import 'package:super_dns_client/src/dns_over_https_binary.dart';
import 'package:super_dns_client/src/dns_resolver.dart';
import 'package:super_dns_client/super_dns_client.dart';

void main() async {
  // 🔹 Example 1: Traditional JSON-based DoH (Google)
  final dohGoogle = DnsOverHttps.google();
  final response = await dohGoogle.lookup('google.com');
  for (var address in response) {
    print('DnsOverHttps.google::lookup → ${address.address}');
  }

  final responseSRV = await dohGoogle.lookupDataByRRType(
    '_jmap._tcp.linagora.com',
    RRType.srv,
  );
  for (var srv in responseSRV) {
    print('DnsOverHttps.google::SRV → $srv');
  }

  // 🔹 Example 2: Traditional JSON-based DoH (Cloudflare)
  final dohCloudflare = DnsOverHttps.cloudflare();
  final responseSRVCloudflare = await dohCloudflare.lookupDataByRRType(
    '_jmap._tcp.linagora.com',
    RRType.srv,
  );
  for (var srv in responseSRVCloudflare) {
    print('DnsOverHttps.cloudflare::SRV → $srv');
  }

  // 🔹 Example 3: New Binary DoH client (non-GAFAM resolvers)
  final binaryClient = DnsOverHttpsBinaryClient();

  // A record lookup (Quad9)
  final aRecords = await binaryClient.lookup('google.com');
  for (var ip in aRecords) {
    print('DnsOverHttpsBinary(quad9)::A → ${ip.address}');
  }

  // SRV record lookup (Quad9)
  final srvRecords =
      await binaryClient.lookupSrv(domain: '_jmap._tcp.linagora.com');
  for (var record in srvRecords) {
    print(
      'DnsOverHttpsBinary(quad9)::SRV → priority=${record.priority}, weight=${record.weight}, port=${record.port}, target=${record.target}',
    );
  }

  // 🔹 Example 4: Using custom resolver (e.g. Mullvad - GET only)
  final customResolvers = [
    DnsResolver(
      name: 'mullvad',
      url: Uri.parse('https://doh.mullvad.net/dns-query'),
    ),
  ];
  final binaryCustom =
      DnsOverHttpsBinaryClient(customResolvers: customResolvers);

  try {
    final customSrvRecords = await binaryCustom.lookupSrv(
      domain: '_jmap._tcp.linagora.com',
      resolverName: 'mullvad',
    );

    for (var record in customSrvRecords) {
      print(
        'DnsOverHttpsBinary(mullvad)::SRV → priority=${record.priority}, weight=${record.weight}, port=${record.port}, target=${record.target}',
      );
    }
  } catch (e) {
    print('❌ Mullvad lookup failed: $e');
  }

  // 🔹 Example 5: Handling errors gracefully
  try {
    await binaryClient.lookupSrv(
      domain: 'example.com',
      resolverName: 'unknown',
    );
  } on ArgumentError catch (e) {
    print('❌ Error: ${e.message}');
  } on SocketException catch (e) {
    print('❌ Network error: $e');
  }
}
