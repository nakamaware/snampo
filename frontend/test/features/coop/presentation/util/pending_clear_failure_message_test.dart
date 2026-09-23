import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/retry_pending_clears_use_case.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/presentation/util/pending_clear_failure_message.dart';

void main() {
  final task = PendingClearTask(
    roomCode: 'ABCD23',
    spotId: 'a',
    nickname: 'me',
    localThumbPath: '/t.jpg',
    expiresAt: DateTime.utc(2026),
  );

  test('先に発見されていた場合は発見者の名前を出す', () {
    final message = pendingClearFailureMessage((
      task: task,
      reason: PendingClearFailureReason.alreadyCleared,
      existing: SpotClear(
        spotId: 'a',
        clearedBy: 'x',
        nickname: 'はなこ',
        clearedAt: DateTime.utc(2026),
      ),
    ));

    expect(message, 'ルーム ABCD23 で、先にはなこさんが発見していたため、あなたの発見を共有できませんでした');
  });

  test('ルームが終わっていた場合', () {
    final message = pendingClearFailureMessage((
      task: task,
      reason: PendingClearFailureReason.roomClosed,
      existing: null,
    ));

    expect(message, 'ルーム ABCD23 が終了していたため、あなたの発見を共有できませんでした');
  });
}
