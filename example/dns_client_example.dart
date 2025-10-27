import 'package:super_dns_client/super_dns_client.dart';

void main() async {
  final dns = DnsOverHttps.google();
  final response = await dns.lookup('google.com');
  for (var address in response) {
    print('DnsOverHttps.google::lookup:Address: ${address.toString()}');
  }

  final responseSRV =
      await dns.lookupDataByRRType('_jmap._tcp.linagora.com', RRType.srv);
  for (var address in responseSRV) {
    print('DnsOverHttps.google::lookupRRType:Address: ${address.toString()}');
  }

  final dnsCloudflare = DnsOverHttps.cloudflare();
  final responseSRVCloudflare = await dnsCloudflare.lookupDataByRRType(
    '_jmap._tcp.linagora.com',
    RRType.srv,
  );
  for (var address in responseSRVCloudflare) {
    print(
      'DnsOverHttps.cloudflare::lookupRRType:Address: ${address.toString()}',
    );
  }
}
