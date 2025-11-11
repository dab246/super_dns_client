import 'dart:async';

import 'package:super_dns_client/platform/platform_system_dns.dart';
import 'package:universal_io/io.dart';

import 'base_udp_srv_client.dart';

/// [SystemUdpSrvClient] resolves DNS servers using the underlying
/// system configuration (Android/iOS native, or local resolv.conf).
///
/// It does **not** fallback to public resolvers; higher-level resolvers
/// should handle that if needed.
class SystemUdpSrvClient extends BaseUdpSrvClient {
  SystemUdpSrvClient({super.debugMode, super.timeout});

  @override
  Future<List<InternetAddress>> getDnsServers({String? host}) async {
    final result = <InternetAddress>[];

    // 1️⃣ Android & iOS: Retrieve DNS from native platform
    if (Platform.isAndroid || Platform.isIOS) {
      final dnsList = await PlatformSystemDns.getSystemDns();

      if (dnsList.isNotEmpty) {
        debug('[SystemUdpSrvClient] Platform system DNS: '
            '${dnsList.map((e) => e.address).join(', ')}');
        return dnsList;
      } else {
        debug('[SystemUdpSrvClient] ⚠️ No DNS returned from system');
      }
    }

    // 2️⃣ Linux / macOS: Parse /etc/resolv.conf for local dev
    if (Platform.isLinux || Platform.isMacOS) {
      final file = File('/etc/resolv.conf');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        debug(
          '[SystemUdpSrvClient] DNS from /etc/resolv.conf: ${lines.join(', ')}',
        );
        for (final line in lines) {
          if (line.startsWith('nameserver')) {
            final ip = line.split(' ').last.trim();
            result.add(InternetAddress(ip));
          }
        }
      }
    }

    // 3️⃣ Fallback: No system DNS detected
    if (result.isEmpty) {
      debug('[SystemUdpSrvClient] ⚠️ No system DNS detected.');
    } else {
      debug('[SystemUdpSrvClient] Using system DNS: '
          '${result.map((e) => e.address).join(', ')}');
    }

    return result;
  }
}
