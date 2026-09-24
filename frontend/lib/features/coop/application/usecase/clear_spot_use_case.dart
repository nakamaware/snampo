import 'dart:developer';

import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/photo_judgement.dart';

/// スポットのクリアの結果
sealed class ClearSpotResult {
  const ClearSpotResult();
}

/// 自分が発見者になった
final class ClearSpotCleared extends ClearSpotResult {
  /// [ClearSpotCleared] を作成する
  const ClearSpotCleared();
}

/// 先に他の人が発見していた (自分の写真と採点は手元に残す)
final class ClearSpotAlreadyCleared extends ClearSpotResult {
  /// [ClearSpotAlreadyCleared] を作成する
  const ClearSpotAlreadyCleared(this.existing);

  /// 先に作成されていたクリア
  final SpotClear existing;
}

/// Rules に拒否された (ルームが終わったあと、遊べる期限を過ぎたなど)。撮影は捨てる
final class ClearSpotRejected extends ClearSpotResult {
  /// [ClearSpotRejected] を作成する
  const ClearSpotRejected();
}

/// 通信に失敗した、または時間内に終わらなかった (撮影は捨て、電波の良い場所で撮り直してもらう)
final class ClearSpotFailed extends ClearSpotResult {
  /// [ClearSpotFailed] を作成する
  const ClearSpotFailed();
}

/// 撮影して採点したスポットをクリアにする (1 人のクリアで全員のクリアになる)
///
/// 1. サムネを作ってアップロードし、thumbPath を入れてクリアを作成する。
///    [shareTimeout] 以内に終わらなければ失敗にする (送り直しはしない。撮り直してもらう)
/// 2. 共有できたら、自分の写真と採点を履歴に残す (先に他の人が発見していても残す)。
///    共有に失敗した撮影は、誰もクリアしていない扱いにして履歴に残さない
/// 3. 自分が発見者になったら、履歴に発見者と自分のサムネを反映する
///
/// 最後のクリアで finished にするのは、`clears` を監視しているストア (CoopMissionStore) が行う。
class ClearSpotUseCase {
  /// [ClearSpotUseCase] を作成する
  ClearSpotUseCase({
    required IThumbnailService thumbnails,
    required ICoopStorage storage,
    required IRoomRepository rooms,
    required IHistoryRepository histories,
    DateTime Function()? now,
    this.shareTimeout = const Duration(seconds: 30),
  }) : _thumbnails = thumbnails,
       _storage = storage,
       _rooms = rooms,
       _histories = histories,
       _now = now ?? DateTime.now;

  final IThumbnailService _thumbnails;
  final ICoopStorage _storage;
  final IRoomRepository _rooms;
  final IHistoryRepository _histories;
  final DateTime Function() _now;

  /// サムネのアップロードとクリアの作成を待つ時間
  final Duration shareTimeout;

  /// クリアにする
  Future<ClearSpotResult> call({
    required Room room,
    required String uid,
    required Nickname nickname,
    required SpotId spotId,
    required CheckpointProgress checkpoint,
  }) async {
    final photoPath =
        checkpoint.userPhotoPath ?? (throw ArgumentError('写真がありません'));
    final localThumbPath = await _thumbnails.createThumbnail(photoPath);
    // 他の人も同じ結果を見られるよう、採点も一緒に共有する
    final judgement = PhotoJudgement.ofCheckpoint(checkpoint);
    final CreateClearResult result;
    try {
      result = await _share(
        room,
        uid: uid,
        nickname: nickname,
        spotId: spotId,
        localThumbPath: localThumbPath,
        judgement: judgement,
      ).timeout(shareTimeout);
    } on CoopPermissionDeniedException {
      return const ClearSpotRejected();
    } on Object catch (e) {
      log('発見を共有できなかった: $e', name: 'ClearSpot');
      return const ClearSpotFailed();
    }

    try {
      await _histories.saveCoopUserPhoto(
        roomCode: room.code,
        spotId: spotId,
        checkpoint: checkpoint,
      );
    } on Object catch (e) {
      log('履歴への写真の保存に失敗した: $e', name: 'ClearSpot');
    }
    if (result case ClearAlreadyExists(
      :final existing,
    ) when existing.clearedBy != uid) {
      return ClearSpotAlreadyCleared(existing);
    }
    // 作成できたか、時間切れのあとに届いた自分のクリアが先にあった (どちらも自分が発見者)。
    // 先にあった場合の発見日時は、サーバのクリアに揃える
    await _histories.applyCoopDiscoverer(
      roomCode: room.code,
      spotId: spotId,
      discovererUid: uid,
      discovererNickname: nickname.value,
      judgement: judgement,
      clearedAt: switch (result) {
        ClearAlreadyExists(:final existing) => existing.clearedAt,
        ClearCreated() => checkpoint.achievedAt ?? _now(),
      },
    );
    await _histories.saveCoopThumb(
      roomCode: room.code,
      spotId: spotId,
      sourcePath: localThumbPath,
    );
    return const ClearSpotCleared();
  }

  Future<CreateClearResult> _share(
    Room room, {
    required String uid,
    required Nickname nickname,
    required SpotId spotId,
    required String localThumbPath,
    required PhotoJudgement? judgement,
  }) async {
    final thumbPath = await _storage.uploadThumb(
      code: room.code,
      spotId: spotId,
      uid: uid,
      localPath: localThumbPath,
    );
    return _rooms.createClear(
      room,
      spotId: spotId,
      uid: uid,
      nickname: nickname,
      thumbPath: thumbPath,
      judgement: judgement,
    );
  }
}
