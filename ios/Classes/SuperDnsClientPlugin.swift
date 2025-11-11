import Flutter
import UIKit

public class SuperDnsClientPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "super_dns_client",
      binaryMessenger: registrar.messenger()
    )
    let instance = SuperDnsClientPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getSystemDns" {
      let dnsServers = DnsResolverHelper.systemDnsServers()

      #if DEBUG
      print("📡 [SuperDnsClientPlugin] iOS system DNS (from native): \(dnsServers)")
      #endif

      result(dnsServers)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
