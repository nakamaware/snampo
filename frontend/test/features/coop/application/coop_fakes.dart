import 'dart:async';

import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumb_upload_queue_store.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/entity/thumb_upload_task.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

/// メモリ上のルームリポジトリ
class FakeRoomRepository implements IRoomRepository {
  final rooms = <String, Room>{};
  final members = <String, List<RoomMember>>{};
  final clears = <String, Map<String, SpotClear>>{};
  final thumbPathFills = <String>[];

  /// null 以外なら createClear はこの Future を待つ (オフラインの送信待ちの再現)
  Completer<void>? createClearGate;

  /// 次に createRoom で衝突させる回数
  int collisions = 0;

  /// true なら fetch 系をオフラインとして失敗させる
  bool offline = false;

  DateTime now = DateTime.utc(2026, 9, 23, 10);

  @override
  Future<bool> createRoom(Room room) async {
    if (collisions > 0) {
      collisions--;
      return false;
    }
    if (rooms.containsKey(room.code.value)) {
      return false;
    }
    rooms[room.code.value] = room;
    return true;
  }

  @override
  Future<Room?> fetchRoom(RoomCode code) async {
    if (offline) {
      throw StateError('offline');
    }
    return rooms[code.value];
  }

  @override
  Stream<Room?> watchRoom(RoomCode code) => Stream.value(rooms[code.value]);

  @override
  Future<void> joinRoom(
    Room room, {
    required String uid,
    required String nickname,
  }) async {
    final list = members.putIfAbsent(room.code.value, () => []);
    final index = list.indexWhere((m) => m.uid == uid);
    if (index >= 0) {
      list[index] = list[index].copyWith(nickname: nickname, leftAt: null);
    } else {
      list.add(RoomMember(uid: uid, nickname: nickname, joinedAt: now));
      now = now.add(const Duration(seconds: 1));
    }
  }

  @override
  Future<void> leaveRoom(RoomCode code, String uid) async {
    final list = members[code.value]!;
    final index = list.indexWhere((m) => m.uid == uid);
    list[index] = list[index].copyWith(leftAt: now);
  }

  @override
  Future<List<RoomMember>> fetchMembers(RoomCode code) async =>
      List.of(members[code.value] ?? const []);

  @override
  Stream<List<RoomMember>> watchMembers(RoomCode code) =>
      Stream.value(members[code.value] ?? const []);

  @override
  Future<void> updateSettings(RoomCode code, RoomSettings settings) async {
    rooms[code.value] = rooms[code.value]!.copyWith(settings: settings);
  }

  @override
  Future<void> markGenerating(RoomCode code) async {
    rooms[code.value] = rooms[code.value]!.copyWith(
      status: RoomStatus.generating,
      generationError: null,
    );
  }

  @override
  Future<void> markGenerationFailed(RoomCode code, String reason) async {
    rooms[code.value] = rooms[code.value]!.copyWith(
      status: RoomStatus.waiting,
      generationError: reason,
    );
  }

  @override
  Future<void> markPlaying(
    RoomCode code, {
    required String missionRef,
    required List<String> spotIds,
  }) async {
    rooms[code.value] = rooms[code.value]!.copyWith(
      status: RoomStatus.playing,
      missionRef: missionRef,
      spotIds: spotIds,
      startedAt: now,
    );
  }

  @override
  Future<void> finish(RoomCode code, FinishReason reason) async {
    rooms[code.value] = rooms[code.value]!.copyWith(
      status: RoomStatus.finished,
      finishReason: reason,
      finishedAt: now,
    );
  }

  @override
  Future<CreateClearResult> createClear(
    Room room, {
    required String spotId,
    required String uid,
    required String nickname,
    required String? thumbPath,
  }) async {
    await createClearGate?.future;
    final map = clears.putIfAbsent(room.code.value, () => {});
    final existing = map[spotId];
    if (existing != null) {
      return ClearAlreadyExists(existing);
    }
    map[spotId] = SpotClear(
      spotId: spotId,
      clearedBy: uid,
      nickname: nickname,
      clearedAt: now,
      thumbPath: thumbPath,
    );
    return const ClearCreated();
  }

  /// 指定したユーザーだけが thumbPath を埋められる (Rules の再現)
  String? currentUid;

  @override
  Future<void> fillThumbPath(
    RoomCode code,
    String spotId,
    String thumbPath,
  ) async {
    if (offline) {
      throw StateError('offline');
    }
    final clear = clears[code.value]?[spotId];
    if (clear == null ||
        clear.thumbPath != null ||
        (currentUid != null && clear.clearedBy != currentUid)) {
      throw const CoopPermissionDeniedException();
    }
    clears[code.value]![spotId] = clear.copyWith(thumbPath: thumbPath);
    thumbPathFills.add(thumbPath);
  }

  @override
  Future<List<SpotClear>> fetchClears(RoomCode code) async {
    if (offline) {
      throw StateError('offline');
    }
    return (clears[code.value] ?? const {}).values.toList();
  }

  @override
  Stream<List<SpotClear>> watchClears(RoomCode code) =>
      Stream.value((clears[code.value] ?? const {}).values.toList());
}

/// メモリ上の Storage
class FakeCoopStorage implements ICoopStorage {
  final uploadedThumbs = <String>[];
  final downloadedThumbs = <String>[];

  /// null 以外なら uploadThumb はこの Future を待つ
  Completer<void>? thumbUploadGate;
  Exception? thumbUploadError;
  Exception? bundleUploadError;
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
  Future<MissionEntity> downloadMissionBundle(String missionRef) async =>
      uploadedMission!;

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
    uploadedThumbs.add(path);
    return path;
  }

  @override
  Future<String> downloadThumb(String thumbPath) async {
    downloadedThumbs.add(thumbPath);
    return '/tmp/download/${downloadedThumbs.length}.jpg';
  }
}

/// サムネを作ったことにする
class FakeThumbnailService implements IThumbnailService {
  @override
  Future<String> createThumbnail(String photoPath) async => '$photoPath.thumb';
}

/// メモリ上の再送キュー
class InMemoryThumbUploadQueueStore implements IThumbUploadQueueStore {
  ThumbUploadQueue queue = const ThumbUploadQueue();

  @override
  Future<ThumbUploadQueue> load() async => queue;

  @override
  Future<void> save(ThumbUploadQueue queue) async => this.queue = queue;
}

/// 協力プレイの履歴だけを扱うメモリ上の履歴リポジトリ
class FakeHistoryRepository implements IHistoryRepository {
  final histories = <String, MissionHistory>{};

  MissionHistory _update(
    String roomCode,
    String spotId,
    MissionHistorySpot Function(MissionHistorySpot spot) update,
  ) {
    final history = histories[roomCode]!;
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
    final spots = [...mission.waypoints, mission.destination];
    histories[coop.roomCode] = MissionHistory(
      id: 'history-${coop.roomCode}',
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
  Future<MissionHistory?> getCoopHistory(String roomCode) async =>
      histories[roomCode];

  @override
  Future<void> applyCoopDiscoverer({
    required String roomCode,
    required String spotId,
    required String discovererUid,
    required String discovererNickname,
    required DateTime clearedAt,
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
      ),
    );
  }

  @override
  Future<void> saveCoopThumb({
    required String roomCode,
    required String spotId,
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
    required String roomCode,
    required String spotId,
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
    String roomCode, {
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
