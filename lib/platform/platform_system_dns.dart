import 'package:universal_io/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PlatformSystemDns {
  static const _channel = MethodChannel('super_dns_client');

  static Future<List<InternetAddress>> getSystemDns() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('getSystemDns');
      return (result ?? []).map((e) => InternetAddress(e)).toList();
    } catch (e) {
      debugPrint('[PlatformSystemDns] ⚠️ Failed to get DNS: $e');
      return [];
    }
  }
}
