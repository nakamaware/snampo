import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/application/usecase/clear_spot_use_case.dart';
import 'package:snampo/features/coop/application/usecase/complete_clear_task_use_case.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  final spotId = fx.spot('a');
  final checkpoint = CheckpointProgress(
    userPhotoPath: '/photos/a.jpg',
    achievedAt: fx.createdAt.add(const Duration(minutes: 10)),
  );
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late InMemoryPendingClearRepository queue;
  late FakeHistoryRepository histories;
  late Room room;
  late ClearSpotUseCase useCase;

  setUp(() async {
    rooms = FakeRoomRepository();
    storage = FakeCoopStorage();
    queue = InMemoryPendingClearRepository();
    histories = FakeHistoryRepository();
    room = fx.room();
    await histories.upsertCoopHistory(
      mission: MissionEntity(
        departure: Coordinate(latitude: 35, longitude: 139),
        destination: ImageCoordinate(
          coordinate: Coordinate(latitude: 35, longitude: 139),
          imageBase64: '',
          spotId: spotId,
        ),
        overviewPolyline: 'p',
      ),
      startedAt: fx.createdAt,
      coop: CoopHistoryInfo(
        roomCode: fx.code,
        syncState: CoopSyncState.inProgress,
        isHost: false,
        members: const [],
        expiresAt: room.expiresAt,
        deleteAt: room.deleteAt,
      ),
    );
    useCase = ClearSpotUseCase(
      rooms: rooms,
      storage: storage,
      thumbnails: FakeThumbnailService(),
      queue: queue,
      histories: histories,
      completeClearTask: CompleteClearTaskUseCase(rooms: rooms, queue: queue),
      thumbUploadTimeout: const Duration(milliseconds: 50),
    );
  });

  Future<ClearSpotResult> clear({
    String uid = 'me',
    void Function()? onSharing,
    void Function()? onSharingDone,
  }) => useCase(
    room: room,
    uid: uid,
    nickname: Nickname.parse(uid),
    spotId: spotId,
    checkpoint: checkpoint,
    onSharing: onSharing,
    onSharingDone: onSharingDone,
  );

  test('サムネを先にアップロードし、thumbPath を入れてクリアを作成する', () async {
    final result = await clear();

    expect(result, isA<ClearSpotCleared>());
    final created = rooms.clears[fx.code]![spotId]!;
    expect(created.clearedBy, 'me');
    expect(created.thumbPath, 'rooms/ABCD23/thumbs/a/me.jpg');
    expect(queue.queue.tasks, isEmpty);
  });

  test('自分の写真と、発見者として自分のサムネを履歴に残す', () async {
    await clear();

    final spot = histories.histories[fx.code]!.spots.single;
    expect(spot.userPhotoPath, '/photos/a.jpg');
    expect(spot.discovererUid, 'me');
    expect(spot.discovererThumbPath, 'history:/photos/a.jpg.thumb');
    expect(spot.isCleared, isTrue);
  });

  test('クリアを作成する前にキューへ積む (途中でキルされても次の起動で作り直せる)', () async {
    final gate = Completer<void>();
    rooms.createClearGate = gate;

    final future = clear();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final task = queue.queue.tasks.single;
    expect(task.clearCreated, isFalse);
    expect(task.nickname, Nickname.parse('me'));
    expect(task.expiresAt, room.expiresAt);
    gate.complete();
    await future;
  });

  test('サムネが時間内に終わらなければ thumbPath なしで先にクリアを作成し、サムネの再送だけを残す', () async {
    storage.thumbUploadGate = Completer<void>();

    final result = await clear();

    expect(result, isA<ClearSpotCleared>());
    expect(rooms.clears[fx.code]![spotId]!.thumbPath, isNull);
    final task = queue.queue.tasks.single;
    expect(task.clearCreated, isTrue);
    expect(task.localThumbPath, '/photos/a.jpg.thumb');
  });

  test('サムネのアップロードに失敗しても、クリアを作成してサムネの再送を残す', () async {
    storage.thumbUploadError = Exception('network');

    await clear();

    expect(rooms.clears[fx.code]![spotId], isNotNull);
    expect(queue.queue.tasks.single.clearCreated, isTrue);
  });

  test('先に他の人がクリアしていたら、その発見者を返しキューから取り除く', () async {
    await clear(uid: 'other');
    queue.queue = const PendingClearQueue();

    final result = await clear();

    expect(result, isA<ClearSpotAlreadyCleared>());
    expect((result as ClearSpotAlreadyCleared).existing.clearedBy, 'other');
    expect(queue.queue.tasks, isEmpty);
    // 自分の写真は手元に残す
    expect(
      histories.histories[fx.code]!.spots.single.userPhotoPath,
      '/photos/a.jpg',
    );
  });

  test('「発見を共有中…」はクリアの送信 (オフラインなら送信待ち) を待たずに終える', () async {
    final events = <String>[];
    final gate = Completer<void>();
    rooms.createClearGate = gate;

    final future = clear(
      onSharing: () => events.add('start'),
      onSharingDone: () => events.add('done'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(events, ['start', 'done']);
    gate.complete();
    await future;
  });

  test('Rules に拒否されたら (ルームが終わったあとなど)、共有できなかったとして返しキューから取り除く', () async {
    rooms.rejectClears = true;

    final result = await clear();

    expect(result, isA<ClearSpotRejected>());
    expect(queue.queue.tasks, isEmpty);
    // 自分の写真は手元に残す
    expect(
      histories.histories[fx.code]!.spots.single.userPhotoPath,
      '/photos/a.jpg',
    );
  });
}
