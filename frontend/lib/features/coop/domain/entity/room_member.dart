import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_member.freezed.dart';

/// ルームのメンバー (`rooms/{roomCode}/members/{uid}`)
@freezed
abstract class RoomMember with _$RoomMember {
  /// [RoomMember] を作成する
  const factory RoomMember({
    required String uid,

    /// 入室時点のニックネーム
    required String nickname,
    required DateTime joinedAt,

    /// 「ルームを抜ける」で記録する。ドキュメントは削除しない
    DateTime? leftAt,
  }) = _RoomMember;

  const RoomMember._();

  /// ルームを抜けたか
  bool get hasLeft => leftAt != null;
}
