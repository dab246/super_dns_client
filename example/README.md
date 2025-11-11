# super_dns_client Example

This example demonstrates how to use the **super_dns_client** package on Android, iOS, and Web.

## 🧱 Setup

Ensure you have Flutter installed and connected devices (emulator or Chrome):

```bash
flutter devices
```

## ▶️ Run Example

Android

```bash
flutter run -d emulator-5554
```

iOS

```bash
flutter run -d ios
```

Web

```bash
flutter run -d chrome
```

## Test SRV Lookup

The dns_client_example example file (lib/dns_client_example.dart) performs a DNS SRV lookup using your system DNS resolver:

```dart
void main() async {
  final client = SystemUdpSrvClient(debugMode: true);
  final servers = await client.getDnsServers();
  print('System DNS: ${servers.map((e) => e.address).join(', ')}');

  final srv = await client.lookupSrv('_jmap._tcp.fastmail.com');
  print('SRV result: $srv');
}
```

You can modify the SRV record target to test your own domain:

```dart
final srv = await client.lookupSrv('_jmap._tcp.yourdomain.com');
```

## 📦 Notes

- The example can be run on:
    - Android Emulator 
    - iOS Simulator 
    - Web (Chrome)
- Ensure internet access is enabled in your emulator.