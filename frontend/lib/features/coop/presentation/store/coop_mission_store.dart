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
import 'package:snampo/features/coop/application/usecase/resolve_unshared_captures_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_clears_use_case.dart';
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

    /// 最新の、他の人がその場で発見したこと (そのスポットの結果画面を開く)
    ///
    /// 電波が戻ったときや一度に複数届いた発見では出さない (バナーだけにする)。
    /// 最後のスポットは、ルームの終了に合わせて Mission 画面が開く。
    CoopDiscoveryEvent? discovery,

    /// 他の人がその場で最後のスポットを発見したこと (全スポットがクリアされた)
    ///
    /// ルームの終了に合わせて Mission 画面が、このスポットの結果画面を開く。
    /// ルームに戻ったときや電波が戻ったときに追いついた発見では出さない。
    CoopDiscoveryEvent? finalDiscovery,
  }) = _CoopMissionState;
}

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせて、
///   その場で届いた発見なら、そのスポットの結果画面へ移るためのイベントを出す
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - 確定の条件 ([shouldFinalizeHistory]) を満たしたら履歴を確定する
///   (finished のあとも、サムネを取得するまでは確定しない)
///
/// ルームを抜けたら invalidate して監視を止める (抜けたルームの通知で今の進捗を変えないため)。
@Riverpod(keepAlive: true)
class CoopMissionStore extends _$CoopMissionStore {
  Set<SpotId>? _knownClearedSpotIds;

  /// サーバと同期したクリアを 1 度でも反映したか
  var _hasSyncedWithServer = false;

  /// 前に発見を知らせてから、サーバの最新の値でない (電波が切れていた) 値が届いたか
  var _hasBeenStale = false;
  var _noticeId = 0;
  var _discoveryId = 0;

  /// ミッションの用意 (用意している間だけある)
  Future<void>? _preparation;

  /// 共有の途中でアプリが終了した撮影のうち、捨てるかをまだ決められていないものの番号
  /// (ルームに戻ったときにサーバの `clears` を読めなかった)
  var _unresolvedCaptureIndexes = <int>{};

  /// [_unresolvedCaptureIndexes] を決め終えたときに完了する (用意するたびに作り直す)
  ///
  /// [settleUnsharedCaptures] が、`clears` の反映 (サムネの取得など) を待たずに返すため。
  var _capturesResolved = Completer<void>();
  SpotClearsSnapshot _latestClears = (clears: const [], isUpToDate: false);
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
        final snapshot = next.value;
        if (snapshot != null) {
          _latestClears = snapshot;
          if (!snapshot.isUpToDate) _hasBeenStale = true;
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

  final _finalSpotSynced = Completer<void>();

  /// 全スポットがクリアされた `clears` を反映し、最後のスポットを開く用意ができるまで待つ
  ///
  /// 発見者を進捗に反映し、他の人がその場で最後のスポットを発見したなら
  /// ([CoopMissionState.finalDiscovery])、そのスポットのサムネの取得を試し終える
  /// (取得できなかった場合や時間切れを含む) まで。ほかのスポットのサムネの取り直しや、
  /// そのあとの反映は待たない。
  Future<void> get finalSpotSynced => _finalSpotSynced.future;

  /// `clears` の反映を順番に行う (前の反映が終わってから次を始める)
  void _syncClears() {
    _clearSync = _clearSync.then((_) => _onClears(_latestClears));
  }

  /// 共有の途中で終了した撮影の扱いを、`clears` の反映と同じ順番で決める
  void _enqueueResolveUnsharedCaptures() {
    _clearSync = _clearSync.then(
      (_) => _resolveUnsharedCaptures(_latestClears),
    );
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

  /// バンドルを取得してミッションを端末に用意する
  ///
  /// 済んでいれば何もしない。用意している途中なら、それが終わるのを待つ。
  Future<void> _prepare(Room room) {
    if (state.isReady) {
      return Future.value();
    }
    return _preparation ??= _prepareOnce(
      room,
    ).whenComplete(() => _preparation = null);
  }

  Future<void> _prepareOnce(Room room) async {
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
      _capturesResolved = Completer<void>();
      _unresolvedCaptureIndexes = {
        ...?ref
            .read(missionProgressStoreProvider(MissionSessionKind.coop))
            .value
            ?.unsharedCaptureIndexes,
      };
      if (_unresolvedCaptureIndexes.isEmpty) _markCapturesResolved();
      state = state.copyWith(isReady: true, prepareError: null);
      _enqueueResolveUnsharedCaptures();
      _syncClears();
    } on Object catch (e, st) {
      log('ミッションの用意に失敗した', error: e, stackTrace: st, name: 'CoopMission');
      state = state.copyWith(prepareError: e);
    }
  }

  /// [settleUnsharedCaptures] で、撮影の扱いを決めるのを待つ時間
  ///
  /// サーバからクリアを読むのを待つ時間 ([ResolveUnsharedCapturesUseCase.fetchTimeout])
  /// より長くする。ミッションの用意や前の反映を待ってから読むので、短いと、読めるのに
  /// その前に時間切れになってしまう。そのため読む待ちの時間から決める。
  static final _settleTimeout =
      ResolveUnsharedCapturesUseCase.defaultFetchTimeout * 2;

  /// 結果画面で進捗を片付けてよいか (共有の途中で終了した撮影の扱いを決め終えたか)
  ///
  /// 決める撮影がなければ、すぐに true を返す (サムネの取得など、ほかの反映は待たない)。
  /// あれば、ミッションの用意や撮影の扱いがまだならここで済ませる。[timeout] (既定は
  /// サーバから読むのを待つ時間の 2 倍) までに決められなければ (サーバから読めない、
  /// 前の反映が終わらないなど) false を返す。片付けると、サーバに届いていた撮影の写真まで
  /// 消してしまうため。
  Future<bool> settleUnsharedCaptures({Duration? timeout}) async {
    if (!_hasUnsettledCaptures) return true;
    return _settleUnsharedCaptures().timeout(
      timeout ?? _settleTimeout,
      onTimeout: () {
        log('未共有の撮影の扱いを時間内に決められなかった', name: 'CoopMission');
        return false;
      },
    );
  }

  /// 共有の途中で終了した撮影のうち、扱いを決めていないものがあるか
  bool get _hasUnsettledCaptures {
    if (state.isReady) return _unresolvedCaptureIndexes.isNotEmpty;
    // 用意の前は、端末の進捗から数える (用意のときに、ここから決めるものを作る)
    final progress =
        ref.read(missionProgressStoreProvider(MissionSessionKind.coop)).value;
    return progress?.roomCode == roomCode &&
        progress!.unsharedCaptureIndexes.isNotEmpty;
  }

  Future<bool> _settleUnsharedCaptures() async {
    final room = _room;
    if (!state.isReady && room != null) {
      await _prepare(room);
    }
    if (!state.isReady) {
      // 用意できなければ撮影の扱いを決められない
      return false;
    }
    _enqueueResolveUnsharedCaptures();
    // 決め終えたら返す。前の反映のサムネの取得など、撮影の扱いに関わらない反映は待たない
    await Future.any([_clearSync, _capturesResolved.future]);
    return _unresolvedCaptureIndexes.isEmpty;
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
  Future<void> _onClears(SpotClearsSnapshot snapshot) async {
    if (!state.isReady) {
      return;
    }
    if (snapshot.isUpToDate) {
      // ルームに戻ったときに決められなかった撮影を、サーバの最新の値で決め直す
      await _resolveUnsharedCaptures(snapshot);
    }
    final clears = snapshot.clears;
    // 全スポットがクリアされた clears か (最初の途中経過で決める)
    var isAllClearedClears = false;
    try {
      // 発見者を先に進捗に反映して知らせ、サムネは取得できたものから進捗に反映する。
      // 最後のスポットは、Mission 画面がそのサムネを待ちきれなければ反映できた分で開くため。
      // 途中経過は必ず 1 つ以上流れる ([SyncCoopClearsUseCase.syncInSteps])
      late CoopClearSyncResult result;
      var isFirstStep = true;
      // その場で開くスポットの結果画面は、そのスポットのサムネの取得を試し終えてから開く
      // (開いた結果画面は、あとから届いたサムネに変わらないため。取得できなければ
      // プレースホルダ)。ほかのスポットのサムネの取り直しは待たない
      CoopDiscoveryEvent? pendingDiscovery;
      // 最後のスポットも同じく、そのスポットのサムネの取得を試し終えるまで Mission 画面に
      // 待ってもらう ([finalSpotSynced])
      CoopDiscoveryEvent? pendingFinalDiscovery;
      await for (final step in ref
          .read(syncCoopClearsUseCaseProvider)
          .syncInSteps(roomCode, clears)) {
        result = step;
        _applyDiscoveriesToProgress(step.discoveries);
        if (isFirstStep) {
          // 発見者を反映した時点で知らせる
          isFirstStep = false;
          final event = await _announceNewDiscoveries(snapshot);
          final room = _room;
          isAllClearedClears = room != null && isAllCleared(room, clears);
          if (event != null && isAllClearedClears) {
            // 全スポットがクリアされたら、ルームの終了に合わせて Mission 画面が
            // 最後のスポットを開く (サムネの取得を待ちきれなくても開けるよう、先に出す)
            state = state.copyWith(finalDiscovery: event);
            pendingFinalDiscovery = event;
          } else {
            pendingDiscovery = event;
          }
          // 最後のスポットの発見を出してから、サムネの取得を待たずに終了にする
          _finishIfAllCleared(clears);
        }
        if (pendingDiscovery != null &&
            _hasTriedThumb(step, pendingDiscovery)) {
          state = state.copyWith(discovery: pendingDiscovery);
          pendingDiscovery = null;
        }
        if (pendingFinalDiscovery != null &&
            _hasTriedThumb(step, pendingFinalDiscovery)) {
          pendingFinalDiscovery = null;
        }
        if (isAllClearedClears && pendingFinalDiscovery == null) {
          _markFinalSpotSynced();
        }
        if (pendingDiscovery == null &&
            pendingFinalDiscovery == null &&
            !identical(snapshot, _latestClears)) {
          // 新しい clears が届いた。残りのサムネの取り直しはその反映に任せ、新しい発見
          // (最後のスポットなど) を出すのを遅らせない
          break;
        }
      }
      if (pendingDiscovery != null) {
        // サムネの取得を試さなかった。反映し終えたら、反映できた分で開く
        state = state.copyWith(discovery: pendingDiscovery);
      }
      final room = _room;
      if (room != null) {
        // 履歴の確定は、終了がルームの通知で届いてからの反映で行う
        await ref.read(finalizeCoopHistoryUseCaseProvider)(
          roomCode: roomCode,
          room: room,
          expiresAt: room.expiresAt,
          hasAllThumbs: result.hasAllThumbs,
        );
      }
    } on Object catch (e, st) {
      log('クリアの反映に失敗した', error: e, stackTrace: st, name: 'CoopMission');
    } finally {
      // 最後のスポットのサムネの取得を試さずに終わっても、Mission 画面を待たせ続けない
      if (isAllClearedClears) _markFinalSpotSynced();
    }
  }

  void _markFinalSpotSynced() {
    if (!_finalSpotSynced.isCompleted) _finalSpotSynced.complete();
  }

  /// 全スポットがクリアされていれば、ルームを finished にする
  ///
  /// 完了は待たない (オフラインや電波が弱いと、サーバに届くまで終わらず、後の反映や
  /// それを待つ画面の遷移を止めてしまう。送信は SDK が溜めておき、復帰したときに送る)。
  /// 拒否されたら (抜けたあとなど) 記録だけする。次の反映でもう一度試し、ほかのメンバーが
  /// 書いてもよい。
  void _finishIfAllCleared(List<SpotClear> clears) {
    final room = _room;
    if (room == null) return;
    unawaited(
      ref.read(finishIfAllClearedUseCaseProvider)(room, clears).catchError((
        Object e,
        StackTrace st,
      ) {
        log('ルームを終了にできなかった', error: e, stackTrace: st, name: 'CoopMission');
        return false;
      }),
    );
  }

  /// [discovery] のスポットの、発見者のサムネを [synced] までに取得し終えたか
  ///
  /// 反映済みか、取得を試したが取得できなかった (時間切れを含む) なら true。
  bool _hasTriedThumb(
    CoopClearSyncResult synced,
    CoopDiscoveryEvent discovery,
  ) {
    final spotId = _spotIdAt(discovery.spotIndex);
    return spotId != null &&
        (synced.discoveries[spotId]?.thumbPath != null ||
            synced.thumbAttemptedSpotId == spotId);
  }

  void _applyDiscoveriesToProgress(Map<SpotId, CoopDiscovery> found) {
    _progress.applyCoopDiscoveries(roomCode, {
      for (final (index, spot) in _spots.indexed)
        if (found[spot.spotId] case final discovery?) index: discovery,
    });
  }

  /// 他の人の新しい発見を知らせる
  ///
  /// - ルームに戻ったとき (途中参加・復帰) に追いついた発見は、何も知らせない。
  ///   最初はキャッシュの値が届き、アプリを終了していた間の発見はそのあとのサーバの値で
  ///   届くので、サーバの最初の値までを「追いつくまで」とする
  /// - その場で 1 件だけ届いた発見は、バナーを出し、そのスポットの結果画面へ移るイベントを返す
  /// - 電波が戻ったときに届いた発見 (前の値がキャッシュ) や、一度に複数届いた発見は、
  ///   バナーだけにする (複数なら 1 つにまとめる)
  Future<CoopDiscoveryEvent?> _announceNewDiscoveries(
    SpotClearsSnapshot snapshot,
  ) async {
    final clears = snapshot.clears;
    final known = _knownClearedSpotIds;
    _knownClearedSpotIds = clears.map((c) => c.spotId).toSet();
    final isRejoining = known == null || !_hasSyncedWithServer;
    final wasStale = _hasBeenStale;
    if (snapshot.isUpToDate) {
      _hasSyncedWithServer = true;
      _hasBeenStale = false;
    }
    if (isRejoining) {
      return null;
    }
    final uid = await _uid();
    final spots = _spots;
    final found = [
      for (final clear in clears)
        if (!known.contains(clear.spotId) && clear.clearedBy != uid)
          if (spots.indexWhere((s) => s.spotId == clear.spotId) case final index
              when index >= 0)
            (index: index, clear: clear),
    ];
    if (found.isEmpty) {
      return null;
    }
    if (found.length > 1) {
      _notify('他のメンバーが ${found.length} か所のスポットを発見!');
      return null;
    }
    final (:index, :clear) = found.single;
    final name = _displayName(clear.clearedBy, clear.nickname);
    final label = index == spots.length - 1 ? 'GOAL' : 'スポット ${index + 1}';
    _notify('$nameさんが$labelを発見!');
    if (!snapshot.isUpToDate || wasStale) {
      return null;
    }
    return CoopDiscoveryEvent(
      id: ++_discoveryId,
      spotIndex: index,
      discovererName: name,
    );
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

  /// 共有の途中でアプリが終了した撮影 (自分の写真はあるが発見者がいない) を、捨てるか決める
  ///
  /// 共有の結果を待たずに終わっているので、共有できなかった扱いにして捨てる
  /// (もう一度撮影できるようにする)。サーバにそのスポットのクリアがあれば捨てない
  /// ([ResolveUnsharedCapturesUseCase])。[snapshot] がサーバの最新の値ならそれで決め、
  /// そうでなければサーバから読む。読めなければ決めずに残し、次にサーバの最新の値が
  /// 届いたときに決め直す。
  Future<void> _resolveUnsharedCaptures(SpotClearsSnapshot snapshot) async {
    if (_unresolvedCaptureIndexes.isEmpty) return;
    try {
      final checkpoints =
          ref
              .read(missionProgressStoreProvider(MissionSessionKind.coop))
              .value
              ?.checkpoints ??
          const [];
      final captures = <SpotId, CheckpointProgress>{};
      final indexOf = <SpotId, int>{};
      for (final index in _unresolvedCaptureIndexes) {
        final checkpoint =
            index < checkpoints.length ? checkpoints[index] : null;
        if (checkpoint?.userPhotoPath == null) continue;
        final spotId = _spotIdAt(index);
        if (spotId == null) {
          // 共有できないスポットの撮影は捨てる
          await _discardCapture(index);
          continue;
        }
        captures[spotId] = checkpoint!;
        indexOf[spotId] = index;
      }
      final discard = await ref.read(resolveUnsharedCapturesUseCaseProvider)(
        roomCode,
        captures,
        upToDateClears: snapshot.isUpToDate ? snapshot.clears : null,
      );
      if (discard == null) return;
      for (final spotId in discard) {
        await _discardCapture(indexOf[spotId]!);
      }
      // 捨て終えてから決め終えた扱いにする (捨てている途中で進捗を片付けないため)
      _markCapturesResolved();
    } on Object catch (e, st) {
      log('未共有の撮影の扱いを決められなかった', error: e, stackTrace: st, name: 'CoopMission');
    }
  }

  void _markCapturesResolved() {
    _unresolvedCaptureIndexes = {};
    if (!_capturesResolved.isCompleted) _capturesResolved.complete();
  }

  /// 共有できなかった撮影を捨てる (誰もクリアしていない扱いに戻し、撮影できるようにする)
  Future<void> _discardCapture(int spotIndex) async {
    ref.read(cameraStoreProvider.notifier).removePhoto(spotIndex);
    await _progress.discardCapture(roomCode, spotIndex);
  }

  /// ホストが途中終了する
  Future<void> endByHost() => ref.read(endCoopMissionUseCaseProvider)(roomCode);
}
