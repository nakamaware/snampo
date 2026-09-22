import 'package:snampo/features/coop/domain/value_object/clear_thumb.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';

/// Firestore `rooms/{roomCode}/clears/{spotId}`。作成のみ、先着勝ち。
class SpotClear {
  /// クリア写真を Storage に置いたあとで作る。
  ///
  /// [thumb] のパスを [thumbPath] にする。バイナリはここに持たない。
  SpotClear.share({
    required ClearThumb thumb,
    required this.clearedBy,
    required this.nickname,
    required this.clearedAt,
  }) : spotId = thumb.spotId,
       thumbPath = thumb.objectPath;

  /// 地点キー。
  final SpotId spotId;

  /// 発見者の Auth `uid`。
  final PlayerId clearedBy;

  /// 発見者ニックネーム。
  final Nickname nickname;

  /// クリア時刻。
  final DateTime clearedAt;

  /// `rooms/{roomCode}/thumbs/{spotId}.jpg`
  final String thumbPath;
}
