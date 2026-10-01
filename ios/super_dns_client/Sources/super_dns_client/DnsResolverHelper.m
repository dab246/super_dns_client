#import "DnsResolverHelper.h"
#include <resolv.h>
#include <arpa/inet.h>

@implementation DnsResolverHelper

+ (NSArray

<NSString *> *)systemDnsServers {
    NSMutableArray < NSString * > *servers = [NSMutableArray array];

#if DEBUG
    NSLog(@"📡 [DnsResolverHelper] Initializing resolver...");
#endif

    struct __res_state res;
    memset(&res, 0, sizeof(res));

    // Always close previous resolver state before init to prevent caching issue
    res_nclose(&res);

    if (res_ninit(&res) == 0) {
#if DEBUG
        NSLog(@"✅ [DnsResolverHelper] res_ninit() succeeded");
        NSLog(@"🔢 [DnsResolverHelper] Number of name servers: %d", res.nscount);
#endif
        for (int i = 0; i < res.nscount; i++) {
            char ip[INET6_ADDRSTRLEN];
            const char *addrStr = inet_ntop(AF_INET, &res.nsaddr_list[i].sin_addr, ip, sizeof(ip));
            if (addrStr) {
                NSString *ipStr = [NSString stringWithUTF8String:addrStr];
#if DEBUG
                NSLog(@"🌐 [DnsResolverHelper] Found DNS server: %@", ipStr);
#endif
                [servers addObject:ipStr];
            }
        }
        res_nclose(&res);
    } else {
#if DEBUG
        NSLog(@"❌ [DnsResolverHelper] res_ninit() failed");
#endif
    }

#if DEBUG
    if (servers.count == 0) {
        NSLog(@"⚠️ [DnsResolverHelper] No DNS servers found.");
    } else {
        NSLog(@"✅ [DnsResolverHelper] Returning %lu DNS servers", (unsigned long)servers.count);
    }
#endif

    return servers;
}

@end
