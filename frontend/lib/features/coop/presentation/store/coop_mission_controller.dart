import 'dart:async';
import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/coop/application/usecase/clear_spot_use_case.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/mission_session_kind.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

part 'coop_mission_controller.freezed.dart';
part 'coop_mission_controller.g.dart';

/// 画面に出すお知らせ (発見バナーなど)
@freezed
abstract class CoopNotice with _$CoopNotice {
  /// [CoopNotice] を作成する
  const factory CoopNotice({
    /// 同じ文言でも別のお知らせとして扱うための連番
    required int id,
    required String message,
  }) = _CoopNotice;
}

/// 協力プレイのミッションの状態
@freezed
abstract class CoopMissionState with _$CoopMissionState {
  /// [CoopMissionState] を作成する
  const factory CoopMissionState({
    /// ミッションを端末に用意できたか (バンドルの取得と履歴の作成が済んだか)
    @Default(false) bool isReady,

    /// ミッションの用意に失敗した理由
    Object? prepareError,

    /// サムネを共有中のスポット ID (「発見を共有中…」の表示用)
    @Default(<String>{}) Set<String> sharingSpotIds,

    /// 最新のお知らせ
    CoopNotice? notice,
  }) = _CoopMissionState;
}

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせる
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - finished になったら履歴を確定する
@Riverpod(keepAlive: true)
class CoopMissionController extends _$CoopMissionController {
  late RoomCode _code;
  Set<String>? _knownClearedSpotIds;
  var _noticeId = 0;
  var _preparing = false;
  List<SpotClear> _latestClears = const [];
  Future<void> _clearSync = Future.value();

  @override
  CoopMissionState build(String roomCode) {
    _code = RoomCode.tryParse(roomCode)!;
    ref
      ..listen(coopRoomProvider(roomCode), (_, next) {
        final room = next.value;
        if (room != null) {
          unawaited(_onRoom(room));
        }
      }, fireImmediately: true)
      ..listen(coopClearsProvider(roomCode), (_, next) {
        final clears = next.value;
        if (clears != null) {
          _latestClears = clears;
          _clearSync = _clearSync.then((_) => _onClears(clears));
        }
      }, fireImmediately: true)
      ..listen(coopMembersProvider(roomCode), (_, next) {
        final members = next.value;
        if (members != null && (stateOrNull?.isReady ?? false)) {
          unawaited(_updateHistoryMembers(members));
        }
      });
    return const CoopMissionState();
  }

  Future<String> _uid() => ref.read(coopAuthServiceProvider).ensureSignedIn();

  void _notify(String message) {
    state = state.copyWith(
      notice: CoopNotice(id: ++_noticeId, message: message),
    );
  }

  Future<void> _onRoom(Room room) async {
    if (room.status == RoomStatus.playing ||
        room.status == RoomStatus.finished) {
      await _prepare(room);
    }
    if (room.status == RoomStatus.finished && state.isReady) {
      await _clearSync;
      await _onClears(_latestClears);
      await ref
          .read(historyRepositoryProvider)
          .finalizeCoopHistory(
            room.code.value,
            completedAt: room.finishedAt ?? DateTime.now(),
          );
    }
  }

  /// バンドルを取得してミッションを端末に用意する (済んでいれば何もしない)
  Future<void> _prepare(Room room) async {
    if (state.isReady || _preparing) {
      return;
    }
    _preparing = true;
    try {
      final progressNotifier = ref.read(
        missionProgressStoreProvider(MissionSessionKind.coop).notifier,
      );
      final persistedNotifier = ref.read(
        persistedMissionProvider(MissionSessionKind.coop).notifier,
      );
      final progress = await ref.read(
        missionProgressStoreProvider(MissionSessionKind.coop).future,
      );
      var mission = await ref.read(
        persistedMissionProvider(MissionSessionKind.coop).future,
      );
      final alreadyPrepared =
          mission != null && progress?.roomCode == room.code.value;
      if (!alreadyPrepared) {
        final missionRef =
            room.missionRef ?? (throw StateError('missionRef がありません'));
        mission = await ref
            .read(coopStorageProvider)
            .downloadMissionBundle(missionRef);
        // 前のルームの進捗 (写真は履歴にコピー済み) を片付けてから始める
        await progressNotifier.clearProgress();
        persistedNotifier.setMission(mission);
        progressNotifier.startProgress(
          mission.waypoints.length + 1,
          roomCode: room.code.value,
        );
      }
      await _upsertHistory(
        room,
        mission,
        await ref.read(roomRepositoryProvider).fetchMembers(room.code),
      );
      state = state.copyWith(isReady: true, prepareError: null);
      _clearSync = _clearSync.then((_) => _onClears(_latestClears));
    } on Object catch (e, st) {
      log('ミッションの用意に失敗した', error: e, stackTrace: st, name: 'CoopMission');
      state = state.copyWith(prepareError: e);
    } finally {
      _preparing = false;
    }
  }

  Future<void> _upsertHistory(
    Room room,
    MissionEntity mission,
    List<RoomMember> members,
  ) async {
    await ref
        .read(historyRepositoryProvider)
        .upsertCoopHistory(
          mission: mission,
          startedAt: room.startedAt ?? room.createdAt,
          coop: CoopHistoryInfo(
            roomCode: room.code.value,
            syncState: CoopSyncState.inProgress,
            isHost: room.isHost(await _uid()),
            members: [
              for (final m in members)
                CoopHistoryMember(uid: m.uid, nickname: m.nickname),
            ],
            expiresAt: room.expiresAt,
            deleteAt: room.deleteAt,
          ),
        );
  }

  Future<void> _updateHistoryMembers(List<RoomMember> members) async {
    final room = ref.read(coopRoomProvider(_code.value)).value;
    final mission =
        ref.read(persistedMissionProvider(MissionSessionKind.coop)).value;
    if (room == null || mission == null) {
      return;
    }
    try {
      await _upsertHistory(room, mission, members);
    } on Object catch (e) {
      log('メンバー一覧の更新に失敗した: $e', name: 'CoopMission');
    }
  }

  /// `clears` を履歴と進捗に反映する
  Future<void> _onClears(List<SpotClear> clears) async {
    if (!state.isReady) {
      return;
    }
    try {
      await ref.read(syncCoopClearsUseCaseProvider)(_code.value, clears);
      await _applyHistoryToProgress();
      await _announceNewDiscoveries(clears);
      await _finishIfAllCleared(clears);
    } on Object catch (e, st) {
      log('クリアの反映に失敗した', error: e, stackTrace: st, name: 'CoopMission');
    }
  }

  Future<void> _applyHistoryToProgress() async {
    final history = await ref
        .read(historyRepositoryProvider)
        .getCoopHistory(_code.value);
    if (history == null) {
      return;
    }
    ref
        .read(missionProgressStoreProvider(MissionSessionKind.coop).notifier)
        .applyCoopDiscoveries({
          for (final spot in history.spots)
            if (spot.discovererUid != null)
              spot.sortOrder: (
                uid: spot.discovererUid!,
                nickname: spot.discovererNickname ?? '',
                clearedAt: spot.achievedAt ?? DateTime.now(),
                thumbPath: spot.discovererThumbPath,
              ),
        });
  }

  Future<void> _announceNewDiscoveries(List<SpotClear> clears) async {
    final known = _knownClearedSpotIds;
    _knownClearedSpotIds = clears.map((c) => c.spotId).toSet();
    // 最初の読み込み (途中参加・復帰) ではバナーを出さない
    if (known == null) {
      return;
    }
    final uid = await _uid();
    final mission =
        ref.read(persistedMissionProvider(MissionSessionKind.coop)).value;
    if (mission == null) {
      return;
    }
    final spots = [...mission.waypoints, mission.destination];
    for (final clear in clears) {
      if (known.contains(clear.spotId) || clear.clearedBy == uid) {
        continue;
      }
      final index = spots.indexWhere((s) => s.spotId == clear.spotId);
      final label = index == spots.length - 1 ? 'GOAL' : 'スポット ${index + 1}';
      _notify('${clear.nickname}さんが$labelを発見!');
    }
  }

  Future<void> _finishIfAllCleared(List<SpotClear> clears) async {
    final room = ref.read(coopRoomProvider(_code.value)).value;
    if (room == null ||
        room.status != RoomStatus.playing ||
        !isAllCleared(room, clears) ||
        !room.isPlayable(DateTime.now())) {
      return;
    }
    // 書き込みが競合しても結果は同じなので、どの端末が書いてもよい
    try {
      await ref
          .read(roomRepositoryProvider)
          .finish(room.code, FinishReason.allCleared);
    } on Object catch (e) {
      log('finished への更新に失敗した: $e', name: 'CoopMission');
    }
  }

  /// 撮影して採点したスポットをクリアにする
  ///
  /// 自分の写真と採点は、先に他の人が発見していても手元 (進捗と履歴) に残す。
  Future<void> clearSpot({
    required int spotIndex,
    required CheckpointProgress checkpoint,
  }) async {
    final room = ref.read(coopRoomProvider(_code.value)).value;
    final mission =
        ref.read(persistedMissionProvider(MissionSessionKind.coop)).value;
    final photoPath = checkpoint.userPhotoPath;
    if (room == null || mission == null || photoPath == null) {
      return;
    }
    final spots = [...mission.waypoints, mission.destination];
    final rawSpotId = spots[spotIndex].spotId;
    if (rawSpotId == null) {
      return;
    }
    final histories = ref.read(historyRepositoryProvider);
    try {
      await histories.saveCoopUserPhoto(
        roomCode: _code.value,
        spotId: rawSpotId,
        checkpoint: checkpoint,
      );
    } on Object catch (e) {
      log('履歴への写真の保存に失敗した: $e', name: 'CoopMission');
    }

    final uid = await _uid();
    final nickname =
        ref
            .read(coopMembersProvider(_code.value))
            .value
            ?.firstWhere(
              (m) => m.uid == uid,
              orElse:
                  () => RoomMember(
                    uid: uid,
                    nickname: 'プレイヤー',
                    joinedAt: DateTime.now(),
                  ),
            )
            .nickname;
    try {
      final result = await ref.read(clearSpotUseCaseProvider)(
        room: room,
        uid: uid,
        nickname: nickname ?? 'プレイヤー',
        spotId: SpotId.parse(rawSpotId),
        photoPath: photoPath,
        onSharing:
            () =>
                state = state.copyWith(
                  sharingSpotIds: {...state.sharingSpotIds, rawSpotId},
                ),
      );
      switch (result) {
        case ClearSpotCleared(:final localThumbPath):
          await histories.applyCoopDiscoverer(
            roomCode: _code.value,
            spotId: rawSpotId,
            discovererUid: uid,
            discovererNickname: nickname ?? 'プレイヤー',
            clearedAt: checkpoint.achievedAt ?? DateTime.now(),
          );
          await histories.saveCoopThumb(
            roomCode: _code.value,
            spotId: rawSpotId,
            sourcePath: localThumbPath,
          );
        case ClearSpotAlreadyCleared(:final existing):
          _notify('先に${existing.nickname}さんが発見しました');
      }
      _clearSync = _clearSync.then((_) => _onClears(_latestClears));
    } on Object catch (e, st) {
      log('クリアの共有に失敗した', error: e, stackTrace: st, name: 'CoopMission');
      _notify('発見を共有できませんでした。電波の良い場所で再度お試しください');
    } finally {
      state = state.copyWith(
        sharingSpotIds: {...state.sharingSpotIds}..remove(rawSpotId),
      );
    }
  }

  /// ホストが途中終了する
  Future<void> endByHost() =>
      ref.read(roomRepositoryProvider).finish(_code, FinishReason.hostEnded);
}
