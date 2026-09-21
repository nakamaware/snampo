import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';

/// Firestore `rooms/{roomCode}/clears/{spotId}`。作成のみ、先着勝ち。
class SpotClear {
  /// [SpotClear] を作成する。
  const SpotClear({
    required this.spotId,
    required this.clearedBy,
    required this.clearedAt,
    this.nickname,
    this.thumbPath,
  });

  /// 地点キー。
  final SpotId spotId;

  /// 発見者の Auth `uid`。
  final PlayerId clearedBy;

  /// 発見者ニックネーム。
  final String? nickname;

  /// クリア時刻。
  final DateTime clearedAt;

  /// 任意の撮影写真パス。この PR では使わない。
  final String? thumbPath;
}
