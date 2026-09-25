import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/core/domain/spot_id.dart';

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

    /// サムネの Storage パス (サムネを上げてからクリアを作成するので必ずある)
    required String thumbPath,

    /// 発見者の採点 (他の人も同じ結果を見るため。古いクリアにはない)
    PhotoJudgement? judgement,
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
    if (!hasThumb) {
      thumbs.add(clear);
    }
  }
  return ClearSyncPlan(discoverersToApply: discoverers, thumbsToFetch: thumbs);
}

/// すべてのクリアについて、発見者のサムネが端末にそろったか
bool hasAllClearThumbs({
  required List<SpotClear> clears,
  required Map<SpotId, LocalClearState> local,
}) => clears.every((clear) {
  final state = local[clear.spotId];
  return state != null &&
      state.discovererUid == clear.clearedBy &&
      state.hasThumb;
});
