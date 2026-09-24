import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/application/usecase/clear_spot_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

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
  late FakeHistoryRepository histories;
  late Room room;
  late ClearSpotUseCase useCase;

  setUp(() async {
    rooms = FakeRoomRepository();
    storage = FakeCoopStorage();
    histories = FakeHistoryRepository();
    room = fx.room(spotIds: ['a', 'b']);
    rooms.rooms[fx.code] = room;
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
      thumbnails: FakeThumbnailService(),
      storage: storage,
      rooms: rooms,
      histories: histories,
      shareTimeout: const Duration(milliseconds: 50),
    );
  });

  Future<ClearSpotResult> clear({String uid = 'me'}) => useCase(
    room: room,
    uid: uid,
    nickname: Nickname.parse(uid),
    spotId: spotId,
    checkpoint: checkpoint,
  );

  test('サムネをアップロードしてから、thumbPath を入れてクリアを作成する', () async {
    final result = await clear();

    expect(result, isA<ClearSpotCleared>());
    final created = rooms.clears[fx.code]![spotId]!;
    expect(created.clearedBy, 'me');
    expect(created.thumbPath, 'rooms/ABCD23/thumbs/a/me.jpg');
  });

  test('自分の写真と、発見者として自分のサムネを履歴に残す', () async {
    await clear();

    final spot = histories.histories[fx.code]!.spots.single;
    expect(spot.userPhotoPath, '/photos/a.jpg');
    expect(spot.discovererUid, 'me');
    expect(spot.discovererThumbPath, 'history:/photos/a.jpg.thumb');
    expect(spot.isCleared, isTrue);
  });

  test('サムネのアップロードに失敗したら、クリアを作成せず失敗を返し、履歴にも残さない', () async {
    storage.thumbUploadError = Exception('network');

    final result = await clear();

    expect(result, isA<ClearSpotFailed>());
    expect(rooms.clears[fx.code]?[spotId], isNull);
    // 共有に失敗した撮影は捨てる (誰もクリアしていない扱い)
    expect(histories.histories[fx.code]!.spots.single.userPhotoPath, isNull);
  });

  test('サムネのアップロードが時間内に終わらなければ、クリアを作成せず失敗を返す', () async {
    storage.thumbUploadGate = Completer<void>();

    final result = await clear();

    expect(result, isA<ClearSpotFailed>());
    expect(rooms.clears[fx.code]?[spotId], isNull);
  });

  test('クリアの作成が時間内に終わらなければ、失敗を返す', () async {
    rooms.createClearGate = Completer<void>();

    final result = await clear();

    expect(result, isA<ClearSpotFailed>());
  });

  test('先に他の人がクリアしていたら、その発見者を返す', () async {
    await clear(uid: 'other');

    final result = await clear();

    expect((result as ClearSpotAlreadyCleared).existing.clearedBy, 'other');
    // 自分の写真は手元に残す
    expect(
      histories.histories[fx.code]!.spots.single.userPhotoPath,
      '/photos/a.jpg',
    );
  });

  test('時間切れのあとに届いた自分のクリアが先にあれば (撮り直したときなど)、自分が発見者として扱う', () async {
    rooms.clears[fx.code] = {spotId: fx.clear('a', 'me')};

    final result = await clear();

    expect(result, isA<ClearSpotCleared>());
    final spot = histories.histories[fx.code]!.spots.single;
    expect(spot.discovererUid, 'me');
    expect(spot.discovererThumbPath, 'history:/photos/a.jpg.thumb');
    // 発見日時はサーバのクリアに揃える
    expect(spot.achievedAt, fx.clear('a', 'me').clearedAt);
  });

  test('Rules に拒否されたら (ルームが終わったあとなど)、共有できなかったとして返す', () async {
    rooms.rejectClears = true;

    final result = await clear();

    expect(result, isA<ClearSpotRejected>());
    expect(histories.histories[fx.code]!.spots.single.userPhotoPath, isNull);
  });
}
