import 'package:universal_io/io.dart';

import 'base_udp_srv_client.dart';

/// Resolver that uses the system-configured DNS servers.
/// It does NOT fallback to public resolvers — that should be handled by a higher-level resolver.
class SystemUdpSrvClient extends BaseUdpSrvClient {
  SystemUdpSrvClient({super.debugMode});

  @override
  Future<List<InternetAddress>> getDnsServers({String? host}) async {
    final result = <InternetAddress>[];

    // Linux / macOS: parse /etc/resolv.conf
    if (Platform.isLinux || Platform.isMacOS) {
      try {
        final file = File('/etc/resolv.conf');
        if (await file.exists()) {
          final lines = await file.readAsLines();
          for (final line in lines) {
            if (line.startsWith('nameserver')) {
              final ip = line.split(' ').last.trim();
              result.add(InternetAddress(ip));
            }
          }
        }
      } catch (_) {}
    }

    // Android/iOS → rely on system resolver (do not attempt to read system props)
    if (Platform.isAndroid || Platform.isIOS) {
      debug(
        '[SystemUdpSrvClient] ⚠️ Using platform DNS resolver (automatic, no explicit servers)',
      );
      if (host != null) {
        final addresses = await InternetAddress.lookup(host);
        debug('[SystemUdpSrvClient] Using system DNS resolver for $host: '
            '${addresses.map((e) => e.address).join(', ')}');
        result.addAll(addresses);
      }
    }

    // If still empty, just return []
    if (result.isEmpty) {
      debug(
        '[SystemUdpSrvClient] ⚠️ No system DNS found — let higher-level resolver fallback to public DNS.',
      );
    }

    debug('[SystemUdpSrvClient] Using ${result.length} system DNS servers: '
        '${result.map((e) => e.address).join(', ')}');

    return result;
  }
}
