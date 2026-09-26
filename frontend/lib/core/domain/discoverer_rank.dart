/// 発見数ランキングの 1 行
typedef DiscovererRank = ({String uid, int count});

/// 発見数ランキング (発見数の多い順、同数なら入室順)
///
/// [discovererUids] はスポットごとの発見者の uid。
List<DiscovererRank> rankDiscoverers({
  required Iterable<String> discovererUids,
  required List<String> uidsInJoinOrder,
}) {
  final counts = <String, int>{for (final uid in uidsInJoinOrder) uid: 0};
  for (final uid in discovererUids) {
    counts[uid] = (counts[uid] ?? 0) + 1;
  }
  final order = [
    ...uidsInJoinOrder,
    ...counts.keys.where((uid) => !uidsInJoinOrder.contains(uid)),
  ];
  final ranks = [for (final uid in order) (uid: uid, count: counts[uid]!)];
  // List.sort は安定ではないため、入室順のインデックスで同数を並べる
  final indexed =
      ranks.indexed.toList()..sort((a, b) {
        final byCount = b.$2.count.compareTo(a.$2.count);
        return byCount != 0 ? byCount : a.$1.compareTo(b.$1);
      });
  return [for (final (_, rank) in indexed) rank];
}
