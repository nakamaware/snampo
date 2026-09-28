import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_member.freezed.dart';

/// ルームのメンバー (`rooms/{roomCode}/members/{uid}`)
@freezed
abstract class RoomMember with _$RoomMember {
  /// [RoomMember] を作成する
  const factory RoomMember({
    required String uid,

    /// ニックネーム (入室時点。ロビーで変えたらその名前)
    required String nickname,
    required DateTime joinedAt,

    /// 「ルームを抜ける」で記録する。ドキュメントは削除しない
    DateTime? leftAt,

    /// ロビーで名前を変えた時刻 (変えていなければ null)
    DateTime? renamedAt,
  }) = _RoomMember;

  const RoomMember._();

  /// 同じ名前の番号付けに使う時刻 (入室時刻。入室後に名前を変えていればその時刻)
  ///
  /// 入り直すと入室時刻が新しくなるので、それより前の名前変更は使わない。
  DateTime get namedAt {
    final renamed = renamedAt;
    return renamed != null && renamed.isAfter(joinedAt) ? renamed : joinedAt;
  }

  /// ルームを抜けたか
  bool get hasLeft => leftAt != null;
}
