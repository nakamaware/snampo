import 'package:flutter/foundation.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';

/// クリア写真の Cloud Storage オブジェクト。
///
/// `rooms/{roomCode}/thumbs/{spotId}.jpg`
@immutable
class ClearThumb {
  /// [roomCode] と [spotId] からパスを決める。
  const ClearThumb({required this.roomCode, required this.spotId});

  /// ルームコード。
  final RoomCode roomCode;

  /// 地点キー。
  final SpotId spotId;

  /// Storage オブジェクトパス。Firestore にはこの文字列だけを書く。
  String get objectPath => 'rooms/${roomCode.value}/thumbs/${spotId.value}.jpg';

  @override
  bool operator ==(Object other) =>
      other is ClearThumb &&
      other.roomCode == roomCode &&
      other.spotId == spotId;

  @override
  int get hashCode => Object.hash(roomCode, spotId);

  @override
  String toString() => 'ClearThumb($objectPath)';
}
