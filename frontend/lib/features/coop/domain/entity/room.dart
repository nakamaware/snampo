import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';

part 'room.freezed.dart';

/// ルームの状態
enum RoomStatus {
  /// ロビーでメンバーを待っている
  waiting,

  /// ホストの端末がミッションを生成している
  generating,

  /// プレイ中
  playing,

  /// 終了した
  finished,
}

/// ルームが終了した理由
enum FinishReason {
  /// 全スポットがクリアされた
  allCleared,

  /// ホストが途中終了した
  hostEnded,
}

/// ロビーでホストが編集するミッションの設定
@freezed
sealed class RoomSettings with _$RoomSettings {
  /// ランダムモード
  const factory RoomSettings.random({required Radius radius}) =
      RoomSettingsRandom;

  /// 目的地指定モード
  const factory RoomSettings.destination({required Coordinate destination}) =
      RoomSettingsDestination;
}

/// 協力プレイのルーム (`rooms/{roomCode}`)
@freezed
abstract class Room with _$Room {
  /// [Room] を作成する
  const factory Room({
    required RoomCode code,

    /// ホストの Auth uid
    required String hostId,
    required RoomStatus status,
    required RoomSettings settings,
    required DateTime createdAt,

    /// 遊べる期限 (作成から 12 時間)。これを過ぎると書き込みをすべて拒否する
    required DateTime expiresAt,

    /// データの保持期限 (作成から 7 日)。TTL で削除する
    required DateTime deleteAt,

    /// Storage のバンドルのパス。playing で必須
    String? missionRef,

    /// バンドル内のスポットの並び順
    @Default([]) List<SpotId> spotIds,

    /// generating が失敗したときの理由
    String? generationError,
    FinishReason? finishReason,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) = _Room;

  const Room._();

  /// 遊べる期間 (作成から 12 時間)
  static const playableDuration = Duration(hours: 12);

  /// データの保持期間 (作成から 7 日)
  static const retentionDuration = Duration(days: 7);

  /// 人数の上限 (抜けていないメンバー)
  static const maxActiveMembers = 8;

  /// 遊べる期限内か
  bool isPlayable(DateTime now) => now.isBefore(expiresAt);

  /// [uid] がホストか
  bool isHost(String uid) => hostId == uid;
}

/// 入室できない理由
enum JoinRoomError {
  /// 存在しないコード
  notFound,

  /// 遊べる期限切れ
  expired,

  /// 終了済み
  finished,

  /// 満員
  full,
}

/// ルームに入室できるかを判定し、できなければ理由を返す
JoinRoomError? checkJoinable(Room? room, DateTime now) {
  if (room == null) {
    return JoinRoomError.notFound;
  }
  if (!room.isPlayable(now)) {
    return JoinRoomError.expired;
  }
  if (room.status == RoomStatus.finished) {
    return JoinRoomError.finished;
  }
  return null;
}

/// 抜けていないメンバーのうち、入室順で [uid] が上限の人数以内か
///
/// 人数の上限は Rules では強制しないため、入室後にこの判定で守る。
bool isWithinCapacity(List<RoomMember> members, String uid) {
  final active =
      members.where((m) => m.leftAt == null).toList()
        ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
  final index = active.indexWhere((m) => m.uid == uid);
  return index >= 0 && index < Room.maxActiveMembers;
}

/// 全スポットがクリアされたか
bool isAllCleared(Room room, Iterable<SpotClear> clears) {
  if (room.spotIds.isEmpty) {
    return false;
  }
  final cleared = clears.map((c) => c.spotId).toSet();
  return room.spotIds.every(cleared.contains);
}

/// 協力プレイの履歴を「確定」にしてよいか
///
/// 次のどれかなら確定する。確定したら以後は同期しない。
/// - ルームが finished で、発見者のサムネが全部端末にそろった ([hasAllThumbs])
/// - 遊べる期限を過ぎた (サムネの再送は遊べる期限までなので、これ以上は届かない)
/// - ルームが消えていた
///
/// finished になったあとも、サムネは遊べる期限までは再送で届くため、そろうまでは確定しない。
bool shouldFinalizeHistory({
  required Room? room,
  required DateTime expiresAt,
  required DateTime now,
  required bool hasAllThumbs,
}) {
  if (room == null || !now.isBefore(expiresAt)) {
    return true;
  }
  return room.status == RoomStatus.finished && hasAllThumbs;
}
