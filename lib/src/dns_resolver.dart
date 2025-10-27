class DnsResolver {
  final String name;
  final Uri url;
  final bool supportsGet; // DoH method
  final bool isTrusted;   // For your internal classification

  const DnsResolver({
    required this.name,
    required this.url,
    this.supportsGet = false,
    this.isTrusted = true,
  });

  @override
  String toString() => '$name (${url.toString()})';
}
