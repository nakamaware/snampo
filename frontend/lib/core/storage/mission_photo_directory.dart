import 'package:flutter/foundation.dart';
import 'package:snampo/core/domain/room_code.dart';

/// 撮影した写真の保存先 (`mission_photos/` の下のサブディレクトリ)
///
/// - ソロは `mission_photos/solo/`
/// - 協力プレイは `mission_photos/coop/{roomCode}/`
@immutable
sealed class MissionPhotoDirectory {
  const MissionPhotoDirectory._();

  /// ソロの保存先
  const factory MissionPhotoDirectory.solo() = _SoloPhotoDirectory;

  /// 協力プレイの保存先 (ルームごと)
  const factory MissionPhotoDirectory.coop(RoomCode roomCode) =
      _CoopPhotoDirectory;

  /// ルームコードがあれば協力プレイ、なければソロの保存先
  factory MissionPhotoDirectory.of({required RoomCode? roomCode}) =>
      roomCode == null
          ? const MissionPhotoDirectory.solo()
          : MissionPhotoDirectory.coop(roomCode);

  /// `mission_photos/` からの相対パスの要素
  List<String> get segments;
}

final class _SoloPhotoDirectory extends MissionPhotoDirectory {
  const _SoloPhotoDirectory() : super._();

  @override
  List<String> get segments => const ['solo'];
}

final class _CoopPhotoDirectory extends MissionPhotoDirectory {
  const _CoopPhotoDirectory(this.roomCode) : super._();

  final RoomCode roomCode;

  @override
  List<String> get segments => ['coop', roomCode.value];
}
