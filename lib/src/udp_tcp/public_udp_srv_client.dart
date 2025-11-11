import 'package:universal_io/io.dart';

import 'base_udp_srv_client.dart';

/// Resolver that uses a list of public (non-GAFAM) DNS servers.
class PublicUdpSrvClient extends BaseUdpSrvClient {
  static final List<InternetAddress> _defaultPublicDns = [
    InternetAddress('9.9.9.9'), // Quad9
    InternetAddress('149.112.112.112'), // Quad9 secondary
    InternetAddress('94.140.14.14'), // AdGuard
    InternetAddress('94.140.15.15'), // AdGuard secondary
    InternetAddress('208.67.222.222'), // OpenDNS
    InternetAddress('208.67.220.220'), // OpenDNS secondary
    InternetAddress('77.88.8.8'), // Yandex
    InternetAddress('77.88.8.1'), // Yandex secondary
  ];

  final List<InternetAddress> _publicDns;

  PublicUdpSrvClient({
    List<InternetAddress>? customPublicDns,
    super.debugMode,
  }) : _publicDns = [..._defaultPublicDns, ...?customPublicDns];

  @override
  Future<List<InternetAddress>> getDnsServers({String? host}) async =>
      _publicDns;
}
