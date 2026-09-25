import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/di/firebase_provider.dart';
import 'package:snampo/features/coop/application/interface/coop_auth_service.dart';
import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';
import 'package:snampo/features/coop/application/usecase/clear_spot_use_case.dart';
import 'package:snampo/features/coop/application/usecase/create_room_use_case.dart';
import 'package:snampo/features/coop/application/usecase/end_coop_mission_use_case.dart';
import 'package:snampo/features/coop/application/usecase/ensure_coop_sign_in_use_case.dart';
import 'package:snampo/features/coop/application/usecase/finalize_coop_history_use_case.dart';
import 'package:snampo/features/coop/application/usecase/finish_if_all_cleared_use_case.dart';
import 'package:snampo/features/coop/application/usecase/get_coop_signed_in_uid_use_case.dart';
import 'package:snampo/features/coop/application/usecase/join_room_use_case.dart';
import 'package:snampo/features/coop/application/usecase/leave_room_use_case.dart';
import 'package:snampo/features/coop/application/usecase/prepare_coop_mission_use_case.dart';
import 'package:snampo/features/coop/application/usecase/resolve_unshared_captures_use_case.dart';
import 'package:snampo/features/coop/application/usecase/start_coop_mission_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_clears_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_history_use_case.dart';
import 'package:snampo/features/coop/application/usecase/update_room_settings_use_case.dart';
import 'package:snampo/features/coop/application/usecase/upsert_coop_history_use_case.dart';
import 'package:snampo/features/coop/application/usecase/watch_room_use_case.dart';
import 'package:snampo/features/coop/data/coop_auth_service.dart';
import 'package:snampo/features/coop/data/firebase_coop_storage.dart';
import 'package:snampo/features/coop/data/repository/room_repository.dart';
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

/// 協力プレイのサインインを済ませるユースケース
@riverpod
EnsureCoopSignInUseCase ensureCoopSignInUseCase(Ref ref) =>
    EnsureCoopSignInUseCase(ref.read(coopAuthServiceProvider));

/// サインイン済みの uid を返すユースケース (サインインは試さない)
@riverpod
GetCoopSignedInUidUseCase getCoopSignedInUidUseCase(Ref ref) =>
    GetCoopSignedInUidUseCase(ref.read(coopAuthServiceProvider));

/// ルームとメンバー、クリアを監視するユースケース
@riverpod
WatchRoomUseCase watchRoomUseCase(Ref ref) =>
    WatchRoomUseCase(ref.watch(roomRepositoryProvider));

/// ルームを作成するユースケース
@riverpod
CreateRoomUseCase createRoomUseCase(Ref ref) =>
    CreateRoomUseCase(ref.read(roomRepositoryProvider));

/// ルームに入室するユースケース
@riverpod
JoinRoomUseCase joinRoomUseCase(Ref ref) =>
    JoinRoomUseCase(ref.read(roomRepositoryProvider));

/// ルームを抜けるユースケース
@riverpod
LeaveRoomUseCase leaveRoomUseCase(Ref ref) =>
    LeaveRoomUseCase(ref.read(roomRepositoryProvider));

/// ロビーでミッションの設定を変更するユースケース
@riverpod
UpdateRoomSettingsUseCase updateRoomSettingsUseCase(Ref ref) =>
    UpdateRoomSettingsUseCase(ref.read(roomRepositoryProvider));

/// ホストがミッションを生成して配るユースケース
@riverpod
StartCoopMissionUseCase startCoopMissionUseCase(Ref ref) {
  // 呼び出し側は ref.read で取り出すため、この Provider は生成の途中で破棄される。
  // 破棄後に ref を使えないよう、依存するユースケースはここで取り出しておく
  final createRandomMission = ref.read(createRandomMissionUseCaseProvider);
  final createDestinationMission = ref.read(
    createDestinationMissionUseCaseProvider,
  );
  return StartCoopMissionUseCase(
    rooms: ref.read(roomRepositoryProvider),
    storage: ref.read(coopStorageProvider),
    createMission:
        (settings) => switch (settings) {
          RoomSettingsRandom(:final radius) => createRandomMission(radius),
          RoomSettingsDestination(:final destination) =>
            createDestinationMission(destination),
        },
  );
}

/// 協力プレイの履歴を作成・更新するユースケース
@riverpod
UpsertCoopHistoryUseCase upsertCoopHistoryUseCase(Ref ref) =>
    UpsertCoopHistoryUseCase(ref.read(historyRepositoryProvider));

/// ミッションを端末に用意するユースケース
@riverpod
PrepareCoopMissionUseCase prepareCoopMissionUseCase(Ref ref) =>
    PrepareCoopMissionUseCase(
      storage: ref.read(coopStorageProvider),
      rooms: ref.read(roomRepositoryProvider),
      upsertHistory: ref.read(upsertCoopHistoryUseCaseProvider),
    );

/// スポットをクリアにするユースケース
@riverpod
ClearSpotUseCase clearSpotUseCase(Ref ref) => ClearSpotUseCase(
  thumbnails: ref.read(thumbnailServiceProvider),
  storage: ref.read(coopStorageProvider),
  rooms: ref.read(roomRepositoryProvider),
  histories: ref.read(historyRepositoryProvider),
);

/// 共有の途中でアプリが終了した撮影の扱いを決めるユースケース
@riverpod
ResolveUnsharedCapturesUseCase resolveUnsharedCapturesUseCase(Ref ref) =>
    ResolveUnsharedCapturesUseCase(rooms: ref.read(roomRepositoryProvider));

/// 全スポットがクリアされていれば finished にするユースケース
@riverpod
FinishIfAllClearedUseCase finishIfAllClearedUseCase(Ref ref) =>
    FinishIfAllClearedUseCase(ref.read(roomRepositoryProvider));

/// ホストが途中終了するユースケース
@riverpod
EndCoopMissionUseCase endCoopMissionUseCase(Ref ref) =>
    EndCoopMissionUseCase(ref.read(roomRepositoryProvider));

/// `clears` を履歴に反映するユースケース
@riverpod
SyncCoopClearsUseCase syncCoopClearsUseCase(Ref ref) => SyncCoopClearsUseCase(
  storage: ref.read(coopStorageProvider),
  histories: ref.read(historyRepositoryProvider),
);

/// 条件を満たしていれば協力プレイの履歴を確定するユースケース
@riverpod
FinalizeCoopHistoryUseCase finalizeCoopHistoryUseCase(Ref ref) =>
    FinalizeCoopHistoryUseCase(ref.read(historyRepositoryProvider));

/// 未確定の協力プレイ履歴を同期するユースケース
@riverpod
SyncCoopHistoryUseCase syncCoopHistoryUseCase(Ref ref) =>
    SyncCoopHistoryUseCase(
      rooms: ref.read(roomRepositoryProvider),
      histories: ref.read(historyRepositoryProvider),
      syncClears: ref.read(syncCoopClearsUseCaseProvider),
      finalize: ref.read(finalizeCoopHistoryUseCaseProvider),
    );

/// 履歴画面を開いたときに、未確定の協力プレイ履歴を同期する
///
/// サインインの再試行はしない (未サインインなら同期しない)。オフラインや協力プレイを使えない
/// 端末では何もせず、手元の履歴だけを表示する。
@riverpod
Future<void> coopHistorySync(Ref ref) async {
  try {
    if (await ref.read(getCoopSignedInUidUseCaseProvider)() == null) {
      return;
    }
    await ref.read(syncCoopHistoryUseCaseProvider)();
  } on Object catch (e) {
    log('協力プレイ履歴の同期をスキップした: $e', name: 'CoopHistorySync');
  }
}
