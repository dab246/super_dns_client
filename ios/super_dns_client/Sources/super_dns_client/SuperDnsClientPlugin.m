#import "./include/super_dns_client/SuperDnsClientPlugin.h"
#import "DnsResolverHelper.h"

@implementation SuperDnsClientPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"super_dns_client"
                                  binaryMessenger:[registrar messenger]];
  SuperDnsClientPlugin *instance = [[SuperDnsClientPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"getSystemDns" isEqualToString:call.method]) {
    NSArray<NSString *> *dnsServers = [DnsResolverHelper systemDnsServers];

#if DEBUG
    NSLog(@"📡 [SuperDnsClientPlugin] iOS system DNS (from native): %@", dnsServers);
#endif

    result(dnsServers);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
