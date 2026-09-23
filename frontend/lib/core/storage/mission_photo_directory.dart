import 'package:flutter/foundation.dart';

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
  ///
  /// パスとして不正なルームコードなら [ArgumentError] を投げる。
  factory MissionPhotoDirectory.coop(String roomCode) {
    if (!_roomCodePattern.hasMatch(roomCode)) {
      throw ArgumentError.value(roomCode, 'roomCode', '不正なルームコードです');
    }
    return _CoopPhotoDirectory(roomCode);
  }

  /// ルームコードがあれば協力プレイ、なければソロの保存先
  factory MissionPhotoDirectory.of({required String? roomCode}) =>
      roomCode == null
          ? const MissionPhotoDirectory.solo()
          : MissionPhotoDirectory.coop(roomCode);

  static final _roomCodePattern = RegExp(r'^[A-Z0-9]+$');

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

  final String roomCode;

  @override
  List<String> get segments => ['coop', roomCode];
}
