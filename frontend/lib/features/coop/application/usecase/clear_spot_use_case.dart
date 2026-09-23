import 'dart:async';
import 'dart:developer';

import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumb_upload_queue_store.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/entity/thumb_upload_task.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

/// スポットのクリアの結果
sealed class ClearSpotResult {
  const ClearSpotResult();
}

/// 自分が発見者になった
final class ClearSpotCleared extends ClearSpotResult {
  /// [ClearSpotCleared] を作成する
  const ClearSpotCleared({required this.localThumbPath});

  /// 端末に保存した自分のサムネのパス
  final String localThumbPath;
}

/// 先に他の人が発見していた (自分の写真と採点は手元に残す)
final class ClearSpotAlreadyCleared extends ClearSpotResult {
  /// [ClearSpotAlreadyCleared] を作成する
  const ClearSpotAlreadyCleared(this.existing);

  /// 先に作成されていたクリア
  final SpotClear existing;
}

/// 撮影して採点したスポットをクリアにする (1 人のクリアで全員のクリアになる)
///
/// 1. サムネを作ってアップロードする
/// 2. 終わったら thumbPath を入れてクリアを作成する
/// 3. [thumbUploadTimeout] 以内に終わらなければ、thumbPath なしでクリアを先に作成する
///    (発見の同期を優先する)。アップロードは再送キューに積む
class ClearSpotUseCase {
  /// [ClearSpotUseCase] を作成する
  ClearSpotUseCase({
    required IRoomRepository rooms,
    required ICoopStorage storage,
    required IThumbnailService thumbnails,
    required IThumbUploadQueueStore queue,
    this.thumbUploadTimeout = const Duration(seconds: 15),
  }) : _rooms = rooms,
       _storage = storage,
       _thumbnails = thumbnails,
       _queue = queue;

  final IRoomRepository _rooms;
  final ICoopStorage _storage;
  final IThumbnailService _thumbnails;
  final IThumbUploadQueueStore _queue;

  /// サムネのアップロードを待つ時間
  final Duration thumbUploadTimeout;

  /// クリアにする
  ///
  /// [onSharing] はサムネの共有を始めたときに呼ぶ (「発見を共有中…」の表示用)。
  Future<ClearSpotResult> call({
    required Room room,
    required String uid,
    required String nickname,
    required SpotId spotId,
    required String photoPath,
    void Function()? onSharing,
  }) async {
    final localThumbPath = await _thumbnails.createThumbnail(photoPath);
    onSharing?.call();

    String? thumbPath;
    try {
      thumbPath = await _storage
          .uploadThumb(
            code: room.code,
            spotId: spotId,
            uid: uid,
            localPath: localThumbPath,
          )
          .timeout(thumbUploadTimeout);
    } on Object catch (e) {
      log('サムネのアップロードが間に合わなかった: $e', name: 'ClearSpotUseCase');
    }

    final task = ThumbUploadTask(
      roomCode: room.code.value,
      spotId: spotId.value,
      localPath: localThumbPath,
      expiresAt: room.expiresAt,
    );
    if (thumbPath == null) {
      // クリアの作成より先に積み、作成の途中でキルされても再送できるようにする
      await _queue.save((await _queue.load()).enqueue(task));
    }

    final result = await _rooms.createClear(
      room,
      spotId: spotId.value,
      uid: uid,
      nickname: nickname,
      thumbPath: thumbPath,
    );
    switch (result) {
      case ClearCreated():
        return ClearSpotCleared(localThumbPath: localThumbPath);
      case ClearAlreadyExists(:final existing):
        if (thumbPath == null) {
          await _queue.save((await _queue.load()).remove(task));
        }
        return ClearSpotAlreadyCleared(existing);
    }
  }
}
