import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/room_code.dart';

part 'coop_session.freezed.dart';
part 'coop_session.g.dart';

/// 端末で進行中の協力プレイ (Home の「ルームに戻る」に使う)
@freezed
abstract class CoopSession with _$CoopSession {
  /// [CoopSession] を作成する
  const factory CoopSession({
    @RoomCodeConverter() required RoomCode roomCode,

    /// 入室したときの Auth uid (uid が変わった場合は戻れない)
    required String uid,
  }) = _CoopSession;

  /// JSON から [CoopSession] を生成する
  factory CoopSession.fromJson(Map<String, dynamic> json) =>
      _$CoopSessionFromJson(json);
}
