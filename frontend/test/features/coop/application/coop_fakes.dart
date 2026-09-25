import 'dart:async';

import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// メモリ上のルームリポジトリ
class FakeRoomRepository implements IRoomRepository {
  final rooms = <RoomCode, Room>{};
  final members = <RoomCode, List<RoomMember>>{};
  final clears = <RoomCode, Map<SpotId, SpotClear>>{};

  /// 次に createRoom で衝突させる回数
  int collisions = 0;

  /// true なら fetch 系をオフラインとして失敗させる
  bool offline = false;

  /// null 以外なら createClear はこの Future を待つ (オフラインの送信待ちの再現)
  Completer<void>? createClearGate;

  /// null 以外なら fetchClears はこの Future を待つ (電波が弱く、返事が来ない状態の再現)
  Completer<void>? fetchClearsGate;

  /// true なら createClear を Rules の拒否として失敗させる (ルームが終わったあとなど)
  bool rejectClears = false;

  /// null 以外なら finish はこの Future を待つ (オフラインの送信待ちの再現)
  Completer<void>? finishGate;

  /// true なら finish を Rules の拒否として失敗させる (抜けたあとなど)
  bool rejectFinish = false;

  DateTime now = DateTime.utc(2026, 9, 23, 10);

  @override
  Future<bool> createRoom(Room room) async {
    if (collisions > 0) {
      collisions--;
      return false;
    }
    if (rooms.containsKey(room.code)) {
      return false;
    }
    rooms[room.code] = room;
    return true;
  }

  @override
  Future<Room?> fetchRoom(RoomCode code) async {
    if (offline) {
      throw StateError('offline');
    }
    return rooms[code];
  }

  @override
  Stream<Room?> watchRoom(RoomCode code) => Stream.value(rooms[code]);

  @override
  Future<void> joinRoom(
    Room room, {
    required String uid,
    required Nickname nickname,
  }) async {
    final list = members.putIfAbsent(room.code, () => []);
    final index = list.indexWhere((m) => m.uid == uid);
    if (index >= 0) {
      final hasLeft = list[index].hasLeft;
      list[index] = list[index].copyWith(
        nickname: nickname.value,
        leftAt: null,
        joinedAt: hasLeft ? now : list[index].joinedAt,
      );
      if (hasLeft) {
        now = now.add(const Duration(seconds: 1));
      }
    } else {
      list.add(RoomMember(uid: uid, nickname: nickname.value, joinedAt: now));
      now = now.add(const Duration(seconds: 1));
    }
  }

  @override
  Future<void> leaveRoom(RoomCode code, String uid) async {
    final list = members[code]!;
    final index = list.indexWhere((m) => m.uid == uid);
    list[index] = list[index].copyWith(leftAt: now);
  }

  @override
  Future<List<RoomMember>> fetchMembers(RoomCode code) async {
    if (offline) {
      throw StateError('offline');
    }
    return List.of(members[code] ?? const []);
  }

  @override
  Stream<List<RoomMember>> watchMembers(RoomCode code) =>
      Stream.value(members[code] ?? const []);

  @override
  Future<void> updateSettings(RoomCode code, RoomSettings settings) async {
    rooms[code] = rooms[code]!.copyWith(settings: settings);
  }

  @override
  Future<void> markGenerating(RoomCode code) async {
    rooms[code] = rooms[code]!.copyWith(
      status: RoomStatus.generating,
      generationError: null,
    );
  }

  @override
  Future<void> markGenerationFailed(RoomCode code, String reason) async {
    rooms[code] = rooms[code]!.copyWith(
      status: RoomStatus.waiting,
      generationError: reason,
    );
  }

  @override
  Future<void> markPlaying(
    RoomCode code, {
    required String missionRef,
    required List<SpotId> spotIds,
  }) async {
    rooms[code] = rooms[code]!.copyWith(
      status: RoomStatus.playing,
      missionRef: missionRef,
      spotIds: spotIds,
      startedAt: now,
    );
  }

  @override
  Future<void> finish(RoomCode code, FinishReason reason) async {
    await finishGate?.future;
    if (rejectFinish) {
      throw const CoopPermissionDeniedException();
    }
    rooms[code] = rooms[code]!.copyWith(
      status: RoomStatus.finished,
      finishReason: reason,
      finishedAt: now,
    );
  }

  @override
  Future<CreateClearResult> createClear(
    Room room, {
    required SpotId spotId,
    required String uid,
    required Nickname nickname,
    required String thumbPath,
    required PhotoJudgement? judgement,
  }) async {
    await createClearGate?.future;
    if (rejectClears) {
      throw const CoopPermissionDeniedException();
    }
    final map = clears.putIfAbsent(room.code, () => {});
    final existing = map[spotId];
    if (existing != null) {
      return ClearAlreadyExists(existing);
    }
    map[spotId] = SpotClear(
      spotId: spotId,
      clearedBy: uid,
      nickname: nickname.value,
      clearedAt: now,
      thumbPath: thumbPath,
      judgement: judgement,
    );
    return const ClearCreated();
  }

  @override
  Future<List<SpotClear>> fetchClears(RoomCode code) async {
    await fetchClearsGate?.future;
    if (offline) {
      throw StateError('offline');
    }
    return (clears[code] ?? const {}).values.toList();
  }

  @override
  Stream<SpotClearsSnapshot> watchClears(RoomCode code) => Stream.value((
    clears: (clears[code] ?? const {}).values.toList(),
    isUpToDate: true,
  ));
}

/// メモリ上の Storage
class FakeCoopStorage implements ICoopStorage {
  final downloadedThumbs = <String>[];

  /// null 以外なら uploadThumb はこの Future を待つ
  Completer<void>? thumbUploadGate;

  /// null 以外なら downloadThumb はこの Future を待つ
  Completer<void>? thumbDownloadGate;
  Exception? thumbUploadError;
  Exception? thumbDownloadError;
  Exception? bundleUploadError;
  Exception? bundleDownloadError;
  MissionEntity? uploadedMission;

  @override
  Future<String> uploadMissionBundle(
    RoomCode code,
    MissionEntity mission,
  ) async {
    if (bundleUploadError != null) {
      throw bundleUploadError!;
    }
    uploadedMission = mission;
    return 'rooms/${code.value}/mission/bundle.json';
  }

  @override
  Future<MissionEntity> downloadMissionBundle(String missionRef) async {
    if (bundleDownloadError != null) {
      throw bundleDownloadError!;
    }
    return uploadedMission!;
  }

  @override
  Future<String> uploadThumb({
    required RoomCode code,
    required SpotId spotId,
    required String uid,
    required String localPath,
  }) async {
    await thumbUploadGate?.future;
    if (thumbUploadError != null) {
      throw thumbUploadError!;
    }
    final path = 'rooms/${code.value}/thumbs/${spotId.pathSegment}/$uid.jpg';
    return path;
  }

  @override
  Future<String> downloadThumb(String thumbPath) async {
    await thumbDownloadGate?.future;
    if (thumbDownloadError != null) {
      throw thumbDownloadError!;
    }
    downloadedThumbs.add(thumbPath);
    return '/tmp/download/${downloadedThumbs.length}.jpg';
  }
}

/// サムネを作ったことにする
class FakeThumbnailService implements IThumbnailService {
  @override
  Future<String> createThumbnail(String photoPath) async => '$photoPath.thumb';
}

/// 協力プレイの履歴だけを扱うメモリ上の履歴リポジトリ
class FakeHistoryRepository implements IHistoryRepository {
  final histories = <RoomCode, MissionHistory>{};

  MissionHistory? _update(
    RoomCode roomCode,
    SpotId spotId,
    MissionHistorySpot Function(MissionHistorySpot spot) update,
  ) {
    final history = histories[roomCode];
    if (history == null) {
      return null;
    }
    return histories[roomCode] = history.copyWith(
      spots: [
        for (final spot in history.spots)
          spot.spotId == spotId ? update(spot) : spot,
      ],
    );
  }

  @override
  Future<void> upsertCoopHistory({
    required MissionEntity mission,
    required DateTime startedAt,
    required CoopHistoryInfo coop,
  }) async {
    final existing = histories[coop.roomCode];
    if (existing != null) {
      histories[coop.roomCode] = existing.copyWith(
        coop: existing.coop!.copyWith(members: coop.members),
      );
      return;
    }
    final spots = mission.spots;
    histories[coop.roomCode] = MissionHistory(
      id: 'history-${coop.roomCode.value}',
      completedAt: startedAt,
      startedAt: startedAt,
      departure: mission.departure,
      overviewPolyline: mission.overviewPolyline,
      settings: MissionSettings.random(radius: Radius(meters: 1000)),
      coop: coop,
      spots: [
        for (final (i, spot) in spots.indexed)
          MissionHistorySpot(
            coordinate: spot.coordinate,
            sortOrder: i,
            isDestination: i == spots.length - 1,
            streetViewImagePath: '/sv/$i.jpg',
            spotId: spot.spotId,
            isCleared: false,
          ),
      ],
    );
  }

  @override
  Future<MissionHistory?> getCoopHistory(RoomCode roomCode) async =>
      histories[roomCode];

  @override
  Future<void> applyCoopDiscoverer({
    required RoomCode roomCode,
    required SpotId spotId,
    required String discovererUid,
    required String discovererNickname,
    required DateTime clearedAt,
    required PhotoJudgement? judgement,
  }) async {
    _update(
      roomCode,
      spotId,
      (spot) => spot.copyWith(
        discovererUid: discovererUid,
        discovererNickname: discovererNickname,
        discovererThumbPath:
            spot.discovererUid == discovererUid
                ? spot.discovererThumbPath
                : null,
        achievedAt: clearedAt,
        isCleared: true,
        discovererJudgement: judgement,
      ),
    );
  }

  @override
  Future<void> saveCoopThumb({
    required RoomCode roomCode,
    required SpotId spotId,
    required String sourcePath,
  }) async {
    _update(
      roomCode,
      spotId,
      (spot) => spot.copyWith(discovererThumbPath: 'history:$sourcePath'),
    );
  }

  @override
  Future<void> saveCoopUserPhoto({
    required RoomCode roomCode,
    required SpotId spotId,
    required CheckpointProgress checkpoint,
  }) async {
    _update(
      roomCode,
      spotId,
      (spot) => spot.copyWith(userPhotoPath: checkpoint.userPhotoPath),
    );
  }

  @override
  Future<void> finalizeCoopHistory(
    RoomCode roomCode, {
    required DateTime completedAt,
  }) async {
    final history = histories[roomCode]!;
    histories[roomCode] = history.copyWith(
      completedAt: completedAt,
      coop: history.coop!.copyWith(syncState: CoopSyncState.finalized),
    );
  }

  @override
  Future<List<MissionHistory>> getInProgressCoopHistories() async => [
    for (final h in histories.values)
      if (h.coop!.syncState == CoopSyncState.inProgress) h,
  ];

  @override
  Future<void> deleteHistory(String id) => throw UnimplementedError();

  @override
  Future<List<MissionHistory>> getHistories({int? limit, int offset = 0}) =>
      throw UnimplementedError();

  @override
  Future<MissionHistory?> getHistoryById(String id) =>
      throw UnimplementedError();

  @override
  Future<void> insertHistory({
    required String id,
    required MissionEntity mission,
    required MissionProgressEntity progress,
  }) => throw UnimplementedError();
}
