import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/mission/domain/value_object/photo_judgement.dart';

/// Rules に拒否された (期限切れ、権限なし、先着に負けたなど)
class CoopPermissionDeniedException implements Exception {
  /// [CoopPermissionDeniedException] を作成する
  const CoopPermissionDeniedException([this.message]);

  /// 詳細
  final String? message;

  @override
  String toString() => 'CoopPermissionDeniedException($message)';
}

/// クリアの作成結果
sealed class CreateClearResult {
  const CreateClearResult();
}

/// 自分が発見者になった
final class ClearCreated extends CreateClearResult {
  /// [ClearCreated] を作成する
  const ClearCreated();
}

/// 先にクリアがあった (時間切れのあとに届いた、自分が前に書いたクリアのこともある)
final class ClearAlreadyExists extends CreateClearResult {
  /// [ClearAlreadyExists] を作成する
  const ClearAlreadyExists(this.existing);

  /// 先に作成されていたクリア
  final SpotClear existing;
}

/// ルーム (Firestore) のリポジトリ
abstract class IRoomRepository {
  /// ルームを作成する (create-only)。コードが既に使われていれば false を返す
  Future<bool> createRoom(Room room);

  /// ルームを 1 回だけサーバから取得する (キャッシュは使わない)。存在しなければ null
  ///
  /// オフラインなら例外を投げる。
  Future<Room?> fetchRoom(RoomCode code);

  /// ルームを監視する。消えたら null
  Stream<Room?> watchRoom(RoomCode code);

  /// 入室する。既にメンバーなら (抜けていた場合も) 戻る
  ///
  /// 抜けていた人が戻るときは入室時刻を更新する (人数の上限を入室順で数えるため)。
  Future<void> joinRoom(
    Room room, {
    required String uid,
    required Nickname nickname,
  });

  /// ルームを抜ける (`leftAt` を記録する。ドキュメントは削除しない)
  Future<void> leaveRoom(RoomCode code, String uid);

  /// メンバーを 1 回だけサーバから取得する (キャッシュは使わない)
  Future<List<RoomMember>> fetchMembers(RoomCode code);

  /// メンバーを監視する (入室順)
  Stream<List<RoomMember>> watchMembers(RoomCode code);

  /// 設定を変更する (ホストのみ、waiting のとき)
  Future<void> updateSettings(RoomCode code, RoomSettings settings);

  /// generating にする (ホストのみ)
  Future<void> markGenerating(RoomCode code);

  /// 生成に失敗したので waiting に戻す (ホストのみ)
  Future<void> markGenerationFailed(RoomCode code, String reason);

  /// バンドルのアップロードが完了したので playing にする (ホストのみ)
  Future<void> markPlaying(
    RoomCode code, {
    required String missionRef,
    required List<SpotId> spotIds,
  });

  /// finished にする
  Future<void> finish(RoomCode code, FinishReason reason);

  /// クリアを作成する (先着勝ち)
  ///
  /// サーバと通信して結果を確かめる (トランザクション)。オフラインなら例外を投げ、
  /// 端末に書き込みを溜めない (共有に失敗したら撮り直してもらうため)。
  /// 拒否されたら [CoopPermissionDeniedException] を投げる。
  Future<CreateClearResult> createClear(
    Room room, {
    required SpotId spotId,
    required String uid,
    required Nickname nickname,
    required String thumbPath,
    required PhotoJudgement? judgement,
  });

  /// クリアを 1 回だけサーバから取得する (キャッシュは使わない)
  ///
  /// オフラインなら例外を投げる。古いキャッシュで履歴を確定しないため。
  Future<List<SpotClear>> fetchClears(RoomCode code);

  /// クリアを監視する
  Stream<List<SpotClear>> watchClears(RoomCode code);
}
