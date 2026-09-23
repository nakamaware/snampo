import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/application/usecase/prepare_coop_mission_use_case.dart';
import 'package:snampo/features/coop/application/usecase/upsert_coop_history_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';
import '../coop_history_fixture.dart';

void main() {
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late FakeHistoryRepository histories;
  late PrepareCoopMissionUseCase useCase;
  final room = fx.room().copyWith(
    missionRef: 'rooms/ABCD23/mission/bundle.json',
  );

  setUp(() async {
    rooms = FakeRoomRepository();
    storage = FakeCoopStorage()..uploadedMission = coopMission;
    histories = FakeHistoryRepository();
    useCase = PrepareCoopMissionUseCase(
      storage: storage,
      rooms: rooms,
      upsertHistory: UpsertCoopHistoryUseCase(histories),
    );
    rooms.rooms[fx.code] = room;
    await rooms.joinRoom(room, uid: 'host', nickname: Nickname.parse('たろう'));
    await rooms.joinRoom(room, uid: 'me', nickname: Nickname.parse('はなこ'));
  });

  test('バンドルを取得し、メンバーつきの履歴を「進行中」で作る', () async {
    final mission = await useCase(room, uid: 'me');

    expect(mission, coopMission);
    final coop = histories.histories[fx.code]!.coop!;
    expect(coop.syncState, CoopSyncState.inProgress);
    expect(coop.isHost, isFalse);
    expect(coop.members.map((m) => m.nickname), ['たろう', 'はなこ']);
  });

  test('用意済みのミッションがあれば取得し直さない (ルームに戻った場合)', () async {
    storage.bundleDownloadError = Exception('should not download');

    final mission = await useCase(room, uid: 'me', prepared: coopMission);

    expect(mission, coopMission);
  });

  test('バンドルを取得できなければ例外を投げる (画面で再試行できるように)', () async {
    storage.bundleDownloadError = Exception('network');

    await expectLater(useCase(room, uid: 'me'), throwsException);
    expect(histories.histories, isEmpty);
  });

  test('missionRef がなければ StateError', () async {
    await expectLater(
      useCase(
        room.copyWith(missionRef: null, status: RoomStatus.playing),
        uid: 'me',
      ),
      throwsStateError,
    );
  });
}
