import 'dart:typed_data';

import 'package:snampo/features/coop/application/coop_backend.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/clear_thumb.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';

/// クリア写真を Storage に置いてから `clears` を作る。
class ShareSpotClearUseCase {
  /// [ShareSpotClearUseCase] を作成する。
  const ShareSpotClearUseCase();

  /// [jpeg] を共有する。先着で負けたら null。
  Future<SpotClear?> call({
    required CoopBackend backend,
    required RoomCode roomCode,
    required SpotId spotId,
    required PlayerId clearedBy,
    required Nickname nickname,
    required DateTime clearedAt,
    required Uint8List jpeg,
  }) async {
    if (jpeg.isEmpty) {
      throw ArgumentError.value(jpeg, 'jpeg', 'クリア写真が空です');
    }
    final thumb = ClearThumb(roomCode: roomCode, spotId: spotId);
    await backend.putBytes(objectPath: thumb.objectPath, bytes: jpeg);
    final clear = SpotClear.share(
      thumb: thumb,
      clearedBy: clearedBy,
      nickname: nickname,
      clearedAt: clearedAt,
    );
    final created = await backend.createClear(roomCode: roomCode, clear: clear);
    if (!created) {
      return null;
    }
    return clear;
  }
}
