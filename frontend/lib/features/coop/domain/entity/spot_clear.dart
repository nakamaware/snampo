import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

part 'spot_clear.freezed.dart';

/// スポットのクリア (`rooms/{roomCode}/clears/{spotId}`)
///
/// 1 人のクリアで全員のクリアになる。先着勝ち (作成のみ)。
@freezed
abstract class SpotClear with _$SpotClear {
  /// [SpotClear] を作成する
  const factory SpotClear({
    required SpotId spotId,

    /// 発見者の Auth uid
    required String clearedBy,

    /// 発見時点の発見者のニックネーム
    required String nickname,
    required DateTime clearedAt,

    /// サムネの Storage パス。アップロード失敗時は null で、後から埋める
    String? thumbPath,
  }) = _SpotClear;
}

/// 端末に反映済みのクリアの状態 (スポットごと)
@freezed
abstract class LocalClearState with _$LocalClearState {
  /// [LocalClearState] を作成する
  const factory LocalClearState({
    /// 反映済みの発見者の uid
    required String? discovererUid,

    /// 発見者のサムネを取得済みか
    required bool hasThumb,
  }) = _LocalClearState;
}

/// サーバ (`clears`) と端末の差分から、取りにいくものを決めた結果
@freezed
abstract class ClearSyncPlan with _$ClearSyncPlan {
  /// [ClearSyncPlan] を作成する
  const factory ClearSyncPlan({
    /// 発見者を端末に反映するクリア
    required List<SpotClear> discoverersToApply,

    /// サムネを取得するクリア
    required List<SpotClear> thumbsToFetch,
  }) = _ClearSyncPlan;

  const ClearSyncPlan._();

  /// 何もすることがないか
  bool get isEmpty => discoverersToApply.isEmpty && thumbsToFetch.isEmpty;
}

/// サーバの [clears] と端末の状態 [local] (spotId ごと) を比べ、不足分を返す
///
/// 基本方針は「サーバ (`clears`) が正で、端末は差分を取りにいく」。
ClearSyncPlan planClearSync({
  required List<SpotClear> clears,
  required Map<SpotId, LocalClearState> local,
}) {
  final discoverers = <SpotClear>[];
  final thumbs = <SpotClear>[];
  for (final clear in clears) {
    final state = local[clear.spotId];
    if (state?.discovererUid != clear.clearedBy) {
      discoverers.add(clear);
    }
    final hasThumb = state?.discovererUid == clear.clearedBy && state!.hasThumb;
    if (clear.thumbPath != null && !hasThumb) {
      thumbs.add(clear);
    }
  }
  return ClearSyncPlan(discoverersToApply: discoverers, thumbsToFetch: thumbs);
}

/// すべてのクリアについて、発見者のサムネが端末にそろったか
///
/// 自分の発見は、thumbPath がまだ埋まっていなくても端末にサムネがある。
bool hasAllClearThumbs({
  required List<SpotClear> clears,
  required Map<SpotId, LocalClearState> local,
}) => clears.every((clear) {
  final state = local[clear.spotId];
  return state != null &&
      state.discovererUid == clear.clearedBy &&
      state.hasThumb;
});

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
