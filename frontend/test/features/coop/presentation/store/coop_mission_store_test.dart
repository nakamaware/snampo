import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/coop/application/usecase/get_coop_signed_in_uid_use_case.dart';
import 'package:snampo/features/coop/application/usecase/prepare_coop_mission_use_case.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

import '../../domain/entity/coop_fixtures.dart';

/// 端末の DB を使わない進捗 (まだ何も保存していない)
class _EmptyProgress extends MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build(MissionSessionKind kind) async => null;
}

/// 端末の DB を使わないミッション (まだ何も保存していない)
class _EmptyMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => null;
}

final _mission = MissionEntity(
  departure: Coordinate(latitude: 35, longitude: 139),
  destination: ImageCoordinate(
    coordinate: Coordinate(latitude: 35, longitude: 139),
    imageBase64: '',
  ),
  overviewPolyline: 'p',
);

/// このルームの進捗 (用意済み)
class _PreparedProgress extends MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build(MissionSessionKind kind) async =>
      MissionProgressEntity(startedAt: createdAt, roomCode: code);
}

/// 用意済みのミッション
class _PreparedMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => _mission;
}

class _FakeSignedInUid implements GetCoopSignedInUidUseCase {
  @override
  Future<String?> call() async => 'me';
}

/// 用意した回数を数える
class _FakePrepare implements PrepareCoopMissionUseCase {
  int calls = 0;

  @override
  Future<MissionEntity> call(
    Room room, {
    required String uid,
    MissionEntity? prepared,
  }) async {
    calls++;
    return _mission;
  }
}

void main() {
  group('CoopMissionStore', () {
    test('ルームを先に読み込んでいても (ホームの「ルームに戻る」)、作るときに失敗しない', () async {
      final container = ProviderContainer(
        overrides: [
          coopRoomProvider(code).overrideWith((ref) => Stream.value(room())),
          coopClearsProvider(code).overrideWith((ref) => const Stream.empty()),
          coopMembersProvider(code).overrideWith((ref) => const Stream.empty()),
          missionProgressStoreProvider.overrideWith(_EmptyProgress.new),
          persistedMissionProvider.overrideWith(_EmptyMission.new),
        ],
      );
      addTearDown(container.dispose);

      // ホームがルームの状態を読んでいる
      container.listen(coopRoomProvider(code), (_, __) {});
      await container.read(coopRoomProvider(code).future);

      // ルームに戻ると、すでに届いているルームで最初の通知が来る
      container.listen(coopMissionStoreProvider(code), (_, __) {});
      await pumpEventQueue();

      expect(container.read(coopMissionStoreProvider(code)).isReady, isFalse);
    });

    test('抜けて作り直したあと、同じルームに入り直すと、もう一度用意する', () async {
      final prepare = _FakePrepare();
      final container = ProviderContainer(
        overrides: [
          coopRoomProvider(code).overrideWith((ref) => Stream.value(room())),
          coopClearsProvider(code).overrideWith((ref) => const Stream.empty()),
          coopMembersProvider(code).overrideWith((ref) => const Stream.empty()),
          missionProgressStoreProvider.overrideWith(_PreparedProgress.new),
          persistedMissionProvider.overrideWith(_PreparedMission.new),
          getCoopSignedInUidUseCaseProvider.overrideWithValue(
            _FakeSignedInUid(),
          ),
          prepareCoopMissionUseCaseProvider.overrideWithValue(prepare),
        ],
      );
      addTearDown(container.dispose);
      container.listen(coopRoomProvider(code), (_, __) {});
      await container.read(coopRoomProvider(code).future);
      container.listen(coopMissionStoreProvider(code), (_, __) {});
      await pumpEventQueue();
      expect(container.read(coopMissionStoreProvider(code)).isReady, isTrue);

      // ルームを抜けると作り直す (CoopSessionStore.close)。ルームはまだ読み込んだまま
      container.invalidate(coopMissionStoreProvider(code));
      await pumpEventQueue();

      expect(container.read(coopMissionStoreProvider(code)).isReady, isTrue);
      expect(prepare.calls, 2);
    });
  });
}
