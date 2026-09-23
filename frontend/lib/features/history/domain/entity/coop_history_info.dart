import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/room_code.dart';

part 'coop_history_info.freezed.dart';
part 'coop_history_info.g.dart';

/// 協力プレイの履歴の同期の状態
enum CoopSyncState {
  /// 進行中 (起動時と履歴画面を開いたときに、サーバから差分を取りにいく)
  inProgress,

  /// 確定 (以後は取りにいかない)
  finalized,
}

/// 協力プレイの履歴のメンバー
@freezed
abstract class CoopHistoryMember with _$CoopHistoryMember {
  /// [CoopHistoryMember] を作成する
  const factory CoopHistoryMember({
    /// Auth の uid (将来の account link と「過去に一緒に遊んだ人」のために保存する)
    required String uid,
    required String nickname,
  }) = _CoopHistoryMember;

  /// JSON から [CoopHistoryMember] を生成する
  factory CoopHistoryMember.fromJson(Map<String, dynamic> json) =>
      _$CoopHistoryMemberFromJson(json);
}

/// 協力プレイの履歴の情報
@freezed
abstract class CoopHistoryInfo with _$CoopHistoryInfo {
  /// [CoopHistoryInfo] を作成する
  const factory CoopHistoryInfo({
    required RoomCode roomCode,
    required CoopSyncState syncState,

    /// 自分がホストだったか
    required bool isHost,

    /// メンバー一覧 (入室順)
    required List<CoopHistoryMember> members,

    /// 遊べる期限
    required DateTime expiresAt,

    /// データの保持期限 (これを過ぎるとサーバのデータは消えている)
    required DateTime deleteAt,
  }) = _CoopHistoryInfo;
}
