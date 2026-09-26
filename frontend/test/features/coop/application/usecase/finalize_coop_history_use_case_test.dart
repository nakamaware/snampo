import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/finalize_coop_history_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';
import '../coop_history_fixture.dart';

void main() {
  final expiresAt = fx.createdAt.add(Room.playableDuration);
  late FakeHistoryRepository histories;

  setUp(() async {
    histories = FakeHistoryRepository();
    await seedCoopHistory(histories);
  });

  FinalizeCoopHistoryUseCase useCase(DateTime now) =>
      FinalizeCoopHistoryUseCase(histories, now: () => now);

  test('finished でサムネがそろっていれば、終了時刻で確定する', () async {
    final finishedAt = fx.createdAt.add(const Duration(hours: 2));
    final room = fx
        .room(status: RoomStatus.finished)
        .copyWith(finishedAt: finishedAt);

    final done = await useCase(fx.createdAt.add(const Duration(hours: 3)))(
      roomCode: fx.code,
      room: room,
      expiresAt: expiresAt,
      hasAllThumbs: true,
    );

    expect(done, isTrue);
    final history = histories.histories[fx.code]!;
    expect(history.coop!.syncState, CoopSyncState.finalized);
    expect(history.completedAt, finishedAt);
  });

  test('確定の条件を満たさなければ何もしない', () async {
    final done = await useCase(fx.createdAt.add(const Duration(hours: 3)))(
      roomCode: fx.code,
      room: fx.room(status: RoomStatus.finished),
      expiresAt: expiresAt,
      hasAllThumbs: false,
    );

    expect(done, isFalse);
    expect(
      histories.histories[fx.code]!.coop!.syncState,
      CoopSyncState.inProgress,
    );
  });

  test('遊べる期限で確定したら、完了日時は遊べる期限にする', () async {
    await useCase(expiresAt.add(const Duration(days: 1)))(
      roomCode: fx.code,
      room: fx.room(),
      expiresAt: expiresAt,
      hasAllThumbs: false,
    );

    expect(histories.histories[fx.code]!.completedAt, expiresAt);
  });
}
