import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
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
  });
}
