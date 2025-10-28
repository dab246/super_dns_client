import 'dart:io';

import 'base_udp_srv_client.dart';

/// Resolver that uses the system-configured DNS servers.
/// It does NOT fallback to public resolvers — that should be handled by a higher-level resolver.
class SystemUdpSrvClient extends BaseUdpSrvClient {
  SystemUdpSrvClient({super.debugMode});

  @override
  Future<List<InternetAddress>> getDnsServers() async {
    final result = <InternetAddress>[];

    // Android: getprop system properties
    if (Platform.isAndroid) {
      try {
        final process = await Process.run('getprop', []);
        final lines = (process.stdout as String).split('\n');
        for (final line in lines) {
          if (line.contains('dns') && line.contains(':')) {
            final match = RegExp(r'\[([0-9a-fA-F:.]+)\]').firstMatch(line);
            if (match != null) {
              result.add(InternetAddress(match.group(1)!));
            }
          }
        }
      } catch (_) {}
    }

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

    // iOS: no public API
    if (Platform.isIOS) {
      debug(
        '[SystemUdpSrvClient] ⚠️ iOS does not expose system DNS (no public API)',
      );
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
