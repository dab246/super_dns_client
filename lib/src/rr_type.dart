import 'package:equatable/equatable.dart';

/// Represents a DNS Resource Record (RR) type.
///
/// Each resource record type defines the structure and semantics
/// of data associated with a DNS domain name.
class RRType extends Equatable {
  /// IPv4 address record
  static const RRType a = RRType('A', 1);

  /// Name Server record
  static const RRType ns = RRType('NS', 2);

  /// Canonical Name record
  static const RRType cname = RRType('CNAME', 5);

  /// Start of Authority record
  static const RRType soa = RRType('SOA', 6);

  /// Pointer record (reverse DNS lookup)
  static const RRType ptr = RRType('PTR', 12);

  /// Mail Exchange record
  static const RRType mx = RRType('MX', 15);

  /// Text record
  static const RRType txt = RRType('TXT', 16);

  /// IPv6 address record
  static const RRType aaaa = RRType('AAAA', 28);

  /// Service locator record
  static const RRType srv = RRType('SRV', 33);

  /// Name of the record type (e.g., 'A', 'MX', 'TXT')
  final String name;

  /// Numeric value of the record type (e.g., 1 for A, 15 for MX)
  final int value;

  const RRType(this.name, this.value);

  @override
  List<Object?> get props => [name, value];

  @override
  String toString() => 'RRType($name, $value)';

  /// Returns an [RRType] instance from its numeric value, if known.
  static RRType? fromValue(int value) {
    return {
      1: a,
      2: ns,
      5: cname,
      6: soa,
      12: ptr,
      15: mx,
      16: txt,
      28: aaaa,
      33: srv,
    }[value];
  }

  /// Returns an [RRType] instance from its name, if known.
  static RRType? fromName(String name) {
    switch (name.toUpperCase()) {
      case 'A':
        return a;
      case 'NS':
        return ns;
      case 'CNAME':
        return cname;
      case 'SOA':
        return soa;
      case 'PTR':
        return ptr;
      case 'MX':
        return mx;
      case 'TXT':
        return txt;
      case 'AAAA':
        return aaaa;
      case 'SRV':
        return srv;
      default:
        return null;
    }
  }
}
