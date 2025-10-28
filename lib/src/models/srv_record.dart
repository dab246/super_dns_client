import 'dart:math';

/// Represents a DNS SRV record according to RFC 2782.
///
/// Example:
/// ```dart
/// final record = SrvRecord(
///   name: '_imap._tcp.example.com',
///   target: 'mail.example.com',
///   port: 143,
///   priority: 10,
///   weight: 20,
///   ttl: 600,
/// );
/// ```
class SrvRecord {
  const SrvRecord({
    required this.name,
    required this.target,
    required this.port,
    required this.priority,
    required this.weight,
    required this.ttl,
  });

  /// Factory from Map (for backward compatibility)
  factory SrvRecord.fromMap(Map<String, dynamic> map) {
    return SrvRecord(
      name: map['name'] ?? '',
      target: map['target'] ?? '',
      port: map['port'] ?? 0,
      priority: map['priority'] ?? 0,
      weight: map['weight'] ?? 0,
      ttl: map['ttl'] ?? 300,
    );
  }

  final String name;
  final String target;
  final int port;
  final int priority;
  final int weight;
  final int ttl;

  /// Converts to Map (useful for JSON or debugging)
  Map<String, dynamic> toMap() => {
        'name': name,
        'target': target,
        'port': port,
        'priority': priority,
        'weight': weight,
        'ttl': ttl,
      };

  @override
  String toString() =>
      'SrvRecord(target=$target, port=$port, priority=$priority, weight=$weight, ttl=$ttl)';

  /// Sort helper based on RFC 2782 (priority first)
  static int compare(SrvRecord a, SrvRecord b) {
    if (a.priority != b.priority) {
      return a.priority.compareTo(b.priority);
    }
    return b.weight.compareTo(a.weight);
  }
}

/// Utility to select SRV targets according to RFC 2782.
///
/// The algorithm chooses records by:
/// 1. Grouping by `priority` (lowest first)
/// 2. Within same priority group, picking one based on weight randomness
///
/// Use case:
/// ```dart
/// final selected = SrvRecordSelector.select(records);
/// for (final s in selected) {
///   print('Try ${s.target}:${s.port}');
/// }
/// ```
class SrvRecordSelector {
  static final _rand = Random.secure();

  /// Returns SRV records ordered by RFC 2782 selection rules.
  ///
  /// The first element is the preferred target to try first.
  static List<SrvRecord> select(List<SrvRecord> records) {
    if (records.isEmpty) {
      return [];
    }

    // Group by priority
    final grouped = <int, List<SrvRecord>>{};
    for (final r in records) {
      grouped.putIfAbsent(r.priority, () => []).add(r);
    }

    final sortedPriorities = grouped.keys.toList()..sort();
    final result = <SrvRecord>[];

    for (final priority in sortedPriorities) {
      final group = List<SrvRecord>.from(grouped[priority]!);
      result.addAll(_weightedShuffle(group));
    }

    return result;
  }

  /// Implements the weighted selection algorithm from RFC 2782 section 3.
  ///
  /// Within a priority group:
  /// - sum all weights (W)
  /// - pick random value R ∈ [0, W)
  /// - iterate through records subtracting weight until R < currentWeight
  static List<SrvRecord> _weightedShuffle(List<SrvRecord> group) {
    final output = <SrvRecord>[];
    final pool = List<SrvRecord>.from(group);

    while (pool.isNotEmpty) {
      final totalWeight = pool.fold<int>(0, (sum, r) => sum + r.weight);
      final r = totalWeight > 0 ? _rand.nextInt(totalWeight + 1) : 0;

      int cumulative = 0;
      late SrvRecord chosen;

      for (final record in pool) {
        cumulative += record.weight;
        if (r <= cumulative) {
          chosen = record;
          break;
        }
      }

      output.add(chosen);
      pool.remove(chosen);
    }

    return output;
  }
}
