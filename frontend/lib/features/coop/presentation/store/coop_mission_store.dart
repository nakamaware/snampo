import 'dart:async';
import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/usecase/clear_spot_use_case.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/store/camera_store.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';
import 'package:snampo/features/settings/presentation/store/nickname_store.dart';

part 'coop_mission_store.freezed.dart';
part 'coop_mission_store.g.dart';

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

/// 他の人がスポットを発見したこと (全員でそのスポットの結果画面を見るため)
@freezed
abstract class CoopDiscoveryEvent with _$CoopDiscoveryEvent {
  /// [CoopDiscoveryEvent] を作成する
  const factory CoopDiscoveryEvent({
    /// 同じスポットでも別のイベントとして扱うための連番
    required int id,

    /// 発見されたスポットのインデックス
    required int spotIndex,

    /// 発見者の表示名
    required String discovererName,
  }) = _CoopDiscoveryEvent;
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

    /// サムネを共有中のスポット (「発見を共有中…」の表示用)
    @Default(<SpotId>{}) Set<SpotId> sharingSpotIds,

    /// 最新のお知らせ
    CoopNotice? notice,

    /// 最新の、他の人による発見 (最後のスポットは、ルームの終了に合わせて Mission 画面が開く)
    CoopDiscoveryEvent? discovery,
  }) = _CoopMissionState;
}

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせて、
///   そのスポットの結果画面へ移るためのイベントを出す
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - 確定の条件 ([shouldFinalizeHistory]) を満たしたら履歴を確定する
///   (finished のあとも、サムネを取得するまでは確定しない)
///
/// ルームを抜けたら invalidate して監視を止める (抜けたルームの通知で今の進捗を変えないため)。
@Riverpod(keepAlive: true)
class CoopMissionStore extends _$CoopMissionStore {
  Set<SpotId>? _knownClearedSpotIds;
  var _noticeId = 0;
  var _discoveryId = 0;
  var _preparing = false;
  List<SpotClear> _latestClears = const [];
  Future<void> _clearSync = Future.value();

  @override
  CoopMissionState build(RoomCode roomCode) {
    ref
      ..listen(coopRoomProvider(roomCode), (_, next) {
        final room = next.value;
        if (room != null) {
          // ルームがすでに届いていると (ホームの「ルームに戻る」や、抜けたあとの入り直し)、
          // build の途中で呼ばれる。作り直しの build の間は state に前の値 (isReady: true)
          // が残っていて用意を飛ばしてしまうので、build が終わってから扱う
          unawaited(
            Future.microtask(() async {
              if (ref.mounted) await _onRoom(room);
            }),
          );
        }
      }, fireImmediately: true)
      ..listen(coopClearsProvider(roomCode), (_, next) {
        final clears = next.value;
        if (clears != null) {
          _latestClears = clears;
          _syncClears();
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

  /// 自分の Auth uid
  ///
  /// 通信しない (端末に残っているサインイン状態から読む)。
  Future<String> _uid() async {
    final uid = await ref.read(getCoopSignedInUidUseCaseProvider)();
    return uid ?? (throw StateError('協力プレイにサインインしていません'));
  }

  MissionProgressStoreNotifier get _progress =>
      ref.read(missionProgressStoreProvider(MissionSessionKind.coop).notifier);

  MissionEntity? get _mission =>
      ref.read(persistedMissionProvider(MissionSessionKind.coop)).value;

  Room? get _room => ref.read(coopRoomProvider(roomCode)).value;

  List<ImageCoordinate> get _spots {
    final mission = _mission;
    return mission == null ? const [] : mission.spots;
  }

  /// [index] 番目のスポットの ID (なければ null)
  SpotId? _spotIdAt(int index) {
    final spots = _spots;
    return index < spots.length ? spots[index].spotId : null;
  }

  /// ルーム内での自分のニックネーム
  ///
  /// メンバーを読めなければ、アプリに保存したニックネーム (なければ自動で命名したもの) を使う。
  Nickname _myNickname(String uid) {
    final members =
        ref.read(coopMembersProvider(roomCode)).value ?? const <RoomMember>[];
    for (final member in members) {
      if (member.uid == uid) {
        return Nickname.orAuto(member.nickname);
      }
    }
    return ref.read(nicknameStoreProvider).value ?? Nickname.orAuto('');
  }

  /// メンバーの表示名 (重複した名前には、表示するときだけ入室順に番号を付ける)
  String _displayName(String uid, String fallback) {
    final members =
        ref.read(coopMembersProvider(roomCode)).value ?? const <RoomMember>[];
    return displayNicknames([
          for (final m in members) (uid: m.uid, nickname: m.nickname),
        ])[uid] ??
        fallback;
  }

  void _notify(String message) {
    state = state.copyWith(
      notice: CoopNotice(id: ++_noticeId, message: message),
    );
  }

  /// ここまでに受け取った `clears` を、履歴と進捗に反映し終えるまで待つ
  Future<void> get clearsSynced => _clearSync;

  /// `clears` の反映を順番に行う (前の反映が終わってから次を始める)
  void _syncClears() {
    _clearSync = _clearSync.then((_) => _onClears(_latestClears));
  }

  Future<void> _onRoom(Room room) async {
    if (room.status == RoomStatus.playing ||
        room.status == RoomStatus.finished) {
      await _prepare(room);
    }
    if (room.status == RoomStatus.finished && state.isReady) {
      // 最後の同期で、サムネがそろっていれば履歴を確定する
      _syncClears();
    }
  }

  /// ミッションの用意に失敗したあと、もう一度用意する
  Future<void> retryPrepare() async {
    final room = _room;
    if (room == null) {
      ref.invalidate(coopRoomProvider(roomCode));
      return;
    }
    state = state.copyWith(prepareError: null);
    await _prepare(room);
  }

  /// バンドルを取得してミッションを端末に用意する (済んでいれば何もしない)
  Future<void> _prepare(Room room) async {
    if (state.isReady || _preparing) {
      return;
    }
    _preparing = true;
    try {
      final progress = await ref.read(
        missionProgressStoreProvider(MissionSessionKind.coop).future,
      );
      final saved = await ref.read(
        persistedMissionProvider(MissionSessionKind.coop).future,
      );
      final alreadyPrepared = saved != null && progress?.roomCode == room.code;
      final mission = await ref.read(prepareCoopMissionUseCaseProvider)(
        room,
        uid: await _uid(),
        prepared: alreadyPrepared ? saved : null,
      );
      if (!alreadyPrepared) {
        // 前のルームの進捗 (写真は履歴にコピー済み) を片付けてから始める
        await _progress.restartProgress(
          mission.spots.length,
          roomCode: room.code,
        );
        ref
            .read(persistedMissionProvider(MissionSessionKind.coop).notifier)
            .setMission(mission);
      }
      state = state.copyWith(isReady: true, prepareError: null);
      await _discardUnsharedCaptures();
      _syncClears();
    } on Object catch (e, st) {
      log('ミッションの用意に失敗した', error: e, stackTrace: st, name: 'CoopMission');
      state = state.copyWith(prepareError: e);
    } finally {
      _preparing = false;
    }
  }

  Future<void> _updateHistoryMembers(List<RoomMember> members) async {
    final room = _room;
    final mission = _mission;
    if (room == null || mission == null) {
      return;
    }
    try {
      await ref.read(upsertCoopHistoryUseCaseProvider)(
        room: room,
        mission: mission,
        members: members,
        uid: await _uid(),
      );
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
      final result = await ref.read(syncCoopClearsUseCaseProvider)(
        roomCode,
        clears,
      );
      _applyDiscoveriesToProgress(result.discoveries);
      await _announceNewDiscoveries(clears);
      final room = _room;
      if (room != null) {
        await ref.read(finishIfAllClearedUseCaseProvider)(room, clears);
        await ref.read(finalizeCoopHistoryUseCaseProvider)(
          roomCode: roomCode,
          room: room,
          expiresAt: room.expiresAt,
          hasAllThumbs: result.hasAllThumbs,
        );
      }
    } on Object catch (e, st) {
      log('クリアの反映に失敗した', error: e, stackTrace: st, name: 'CoopMission');
    }
  }

  void _applyDiscoveriesToProgress(Map<SpotId, CoopDiscovery> found) {
    _progress.applyCoopDiscoveries(roomCode, {
      for (final (index, spot) in _spots.indexed)
        if (found[spot.spotId] case final discovery?) index: discovery,
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
    final spots = _spots;
    // 全スポットがクリアされたら、ルームの終了に合わせて Mission 画面が最後のスポットを開く
    final allCleared = clears.length >= spots.length;
    for (final clear in clears) {
      if (known.contains(clear.spotId) || clear.clearedBy == uid) {
        continue;
      }
      final index = spots.indexWhere((s) => s.spotId == clear.spotId);
      if (index < 0) {
        continue;
      }
      final name = _displayName(clear.clearedBy, clear.nickname);
      final label = index == spots.length - 1 ? 'GOAL' : 'スポット ${index + 1}';
      _notify('$nameさんが$labelを発見!');
      if (!allCleared) {
        state = state.copyWith(
          discovery: CoopDiscoveryEvent(
            id: ++_discoveryId,
            spotIndex: index,
            discovererName: name,
          ),
        );
      }
    }
  }

  /// 撮影して採点したスポットをクリアにする
  ///
  /// 自分の写真と採点は、先に他の人が発見していても手元 (進捗と履歴) に残す。
  /// 共有に失敗した撮影は捨て (誰もクリアしていない扱いに戻り、もう一度撮影できる)、
  /// 利用者に表示する理由を返す。共有できたら (先を越された場合を含む) null を返す。
  Future<String?> clearSpot({
    required int spotIndex,
    required CheckpointProgress checkpoint,
  }) async {
    final room = _room;
    final spotId = _spotIdAt(spotIndex);
    if (checkpoint.userPhotoPath == null) {
      return null;
    }
    if (room == null || spotId == null) {
      // 共有できないので、撮影は捨てる
      await _discardCapture(spotIndex);
      return '発見を共有できませんでした。もう一度撮影してください';
    }
    void setSharing({required bool sharing}) {
      final ids = {...state.sharingSpotIds};
      sharing ? ids.add(spotId) : ids.remove(spotId);
      state = state.copyWith(sharingSpotIds: ids);
    }

    setSharing(sharing: true);
    try {
      final uid = await _uid();
      final result = await ref.read(clearSpotUseCaseProvider)(
        room: room,
        uid: uid,
        nickname: _myNickname(uid),
        spotId: spotId,
        checkpoint: checkpoint,
      );
      final String? error;
      switch (result) {
        case ClearSpotCleared():
          error = null;
        case ClearSpotAlreadyCleared(:final existing):
          error = null;
          _notify(
            '先に${_displayName(existing.clearedBy, existing.nickname)}'
            'さんが発見しました',
          );
        case ClearSpotRejected():
          await _discardCapture(spotIndex);
          error = 'ルームが終了していたため、発見を共有できませんでした';
        case ClearSpotFailed():
          await _discardCapture(spotIndex);
          error = '発見を共有できませんでした。電波の良い場所で撮り直してください';
      }
      _syncClears();
      return error;
    } on Object catch (e, st) {
      // 通信の失敗は ClearSpotFailed で返るので、ここに来るのは端末の中の失敗 (サムネの作成など)
      log('クリアの共有に失敗した', error: e, stackTrace: st, name: 'CoopMission');
      await _discardCapture(spotIndex);
      return '発見を共有できませんでした。もう一度撮影してください';
    } finally {
      setSharing(sharing: false);
    }
  }

  /// 共有の途中でアプリが終了した撮影 (自分の写真はあるが発見者がいない) を捨てる
  ///
  /// 共有の結果を待たずに終わっているので、共有できなかった扱いにする
  /// (もう一度撮影できるようにする)。ミッションを端末に用意した直後に呼ぶ。
  ///
  /// サーバにそのスポットのクリアがあれば (共有は届いていて、同期の前に終了した。先着に
  /// 負けた場合を含む) 捨てない。発見者はこのあとの同期で付く。`clears` を読めなければ、
  /// 判断できないので何もしない。
  Future<void> _discardUnsharedCaptures() async {
    final progress = await ref.read(
      missionProgressStoreProvider(MissionSessionKind.coop).future,
    );
    final indexes = [...?progress?.unsharedCaptureIndexes];
    if (indexes.isEmpty) return;
    final List<SpotClear> clears;
    try {
      clears = await ref.read(coopClearsProvider(roomCode).future);
    } on Object catch (e) {
      log('未共有の撮影を確かめられなかった: $e', name: 'CoopMission');
      return;
    }
    final clearedSpotIds = {for (final clear in clears) clear.spotId};
    for (final index in indexes) {
      if (!clearedSpotIds.contains(_spotIdAt(index))) {
        await _discardCapture(index);
      }
    }
  }

  /// 共有できなかった撮影を捨てる (誰もクリアしていない扱いに戻し、撮影できるようにする)
  Future<void> _discardCapture(int spotIndex) async {
    ref.read(cameraStoreProvider.notifier).removePhoto(spotIndex);
    await _progress.discardCapture(roomCode, spotIndex);
  }

  /// ホストが途中終了する
  Future<void> endByHost() => ref.read(endCoopMissionUseCaseProvider)(roomCode);
}
