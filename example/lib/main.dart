import 'package:flutter/material.dart';
import 'package:super_dns_client/super_dns_client.dart';

void main() {
  runApp(const SuperDnsExampleApp());
}

class SuperDnsExampleApp extends StatelessWidget {
  const SuperDnsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'super_dns_client Example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const DnsLookupScreen(),
    );
  }
}

class DnsLookupScreen extends StatefulWidget {
  const DnsLookupScreen({super.key});

  @override
  State<DnsLookupScreen> createState() => _DnsLookupScreenState();
}

class _DnsLookupScreenState extends State<DnsLookupScreen> {
  final _controller = TextEditingController(text: '_jmap._tcp.fastmail.com');
  String _output = '';
  bool _loading = false;

  Future<void> _runLookup() async {
    setState(() {
      _loading = true;
      _output = '';
    });

    try {
      final client = SystemUdpSrvClient(debugMode: true);

      final srvRecords = await client.lookupSrv(_controller.text);

      setState(() {
        _output = '''
SRV lookup for "${_controller.text}":
${srvRecords.isEmpty ? 'No SRV record found' : srvRecords.join('\n')}
''';
      });
    } catch (e, st) {
      setState(() {
        _output = 'Error: $e\n$st';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('super_dns_client Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a SRV record domain to lookup:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '_jmap._tcp.example.com',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onSubmitted: (_) => _runLookup(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _runLookup,
                icon: const Icon(Icons.search),
                label: Text(_loading ? 'Running...' : 'Run SRV Lookup'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Output:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _output.isEmpty ? 'Result will appear here...' : _output,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
