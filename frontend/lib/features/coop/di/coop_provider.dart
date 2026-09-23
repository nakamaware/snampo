import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/di/firebase_provider.dart';
import 'package:snampo/features/coop/application/interface/coop_auth_service.dart';
import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumb_upload_queue_store.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';
import 'package:snampo/features/coop/application/usecase/clear_spot_use_case.dart';
import 'package:snampo/features/coop/application/usecase/create_room_use_case.dart';
import 'package:snampo/features/coop/application/usecase/join_room_use_case.dart';
import 'package:snampo/features/coop/application/usecase/retry_thumb_uploads_use_case.dart';
import 'package:snampo/features/coop/application/usecase/start_coop_mission_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_clears_use_case.dart';
import 'package:snampo/features/coop/data/coop_auth_service.dart';
import 'package:snampo/features/coop/data/firebase_coop_storage.dart';
import 'package:snampo/features/coop/data/repository/room_repository.dart';
import 'package:snampo/features/coop/data/thumb_upload_queue_storage.dart';
import 'package:snampo/features/coop/data/thumbnail_service.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';

part 'coop_provider.g.dart';

/// 協力プレイの認証
@Riverpod(keepAlive: true)
ICoopAuthService coopAuthService(Ref ref) =>
    CoopAuthService(() => ref.read(firebaseSetupProvider.future));

/// ルームのリポジトリ (Firebase の初期化後に使う)
@Riverpod(keepAlive: true)
IRoomRepository roomRepository(Ref ref) =>
    RoomRepository(FirebaseFirestore.instance);

/// 協力プレイの Storage (Firebase の初期化後に使う)
@Riverpod(keepAlive: true)
ICoopStorage coopStorage(Ref ref) =>
    FirebaseCoopStorage(FirebaseStorage.instance);

/// サムネを作るサービス
@riverpod
IThumbnailService thumbnailService(Ref ref) => ThumbnailService();

/// サムネの再送キュー
@Riverpod(keepAlive: true)
IThumbUploadQueueStore thumbUploadQueueStore(Ref ref) =>
    ThumbUploadQueueStorage();

/// ルームを作成するユースケース
@riverpod
CreateRoomUseCase createRoomUseCase(Ref ref) =>
    CreateRoomUseCase(ref.read(roomRepositoryProvider));

/// ルームに入室するユースケース
@riverpod
JoinRoomUseCase joinRoomUseCase(Ref ref) =>
    JoinRoomUseCase(ref.read(roomRepositoryProvider));

/// ホストがミッションを生成して配るユースケース
@riverpod
StartCoopMissionUseCase startCoopMissionUseCase(Ref ref) =>
    StartCoopMissionUseCase(
      rooms: ref.read(roomRepositoryProvider),
      storage: ref.read(coopStorageProvider),
      createMission:
          (settings) => switch (settings) {
            RoomSettingsRandom(:final radius) => ref.read(
              createRandomMissionUseCaseProvider,
            )(radius),
            RoomSettingsDestination(:final destination) => ref.read(
              createDestinationMissionUseCaseProvider,
            )(destination),
          },
    );

/// スポットをクリアにするユースケース
@riverpod
ClearSpotUseCase clearSpotUseCase(Ref ref) => ClearSpotUseCase(
  rooms: ref.read(roomRepositoryProvider),
  storage: ref.read(coopStorageProvider),
  thumbnails: ref.read(thumbnailServiceProvider),
  queue: ref.read(thumbUploadQueueStoreProvider),
);

/// サムネを再送するユースケース (実行中の二重起動を防ぐため keepAlive)
@Riverpod(keepAlive: true)
RetryThumbUploadsUseCase retryThumbUploadsUseCase(Ref ref) =>
    RetryThumbUploadsUseCase(
      rooms: ref.read(roomRepositoryProvider),
      storage: ref.read(coopStorageProvider),
      queue: ref.read(thumbUploadQueueStoreProvider),
      uid: () => ref.read(coopAuthServiceProvider).ensureSignedIn(),
    );

/// `clears` を履歴に反映するユースケース
@riverpod
SyncCoopClearsUseCase syncCoopClearsUseCase(Ref ref) => SyncCoopClearsUseCase(
  storage: ref.read(coopStorageProvider),
  histories: ref.read(historyRepositoryProvider),
);

/// 未確定の協力プレイ履歴を同期するユースケース
@riverpod
SyncCoopHistoryUseCase syncCoopHistoryUseCase(Ref ref) =>
    SyncCoopHistoryUseCase(
      rooms: ref.read(roomRepositoryProvider),
      histories: ref.read(historyRepositoryProvider),
      syncClears: ref.read(syncCoopClearsUseCaseProvider),
    );
