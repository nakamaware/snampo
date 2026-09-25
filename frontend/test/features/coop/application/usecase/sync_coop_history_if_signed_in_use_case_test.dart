import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/get_coop_signed_in_uid_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_history_if_signed_in_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_history_use_case.dart';

class _FakeSignedInUid implements GetCoopSignedInUidUseCase {
  _FakeSignedInUid(this.uid);

  final String? uid;

  @override
  Future<String?> call() async => uid;
}

class _FakeSyncHistory implements SyncCoopHistoryUseCase {
  int calls = 0;
  Exception? error;

  @override
  Future<void> call() async {
    calls++;
    if (error case final e?) throw e;
  }
}

void main() {
  late _FakeSyncHistory syncHistory;

  setUp(() => syncHistory = _FakeSyncHistory());

  SyncCoopHistoryIfSignedInUseCase useCase(String? uid) =>
      SyncCoopHistoryIfSignedInUseCase(
        signedInUid: _FakeSignedInUid(uid),
        syncHistory: syncHistory,
      );

  test('サインイン済みなら、未確定の協力プレイ履歴を同期する', () async {
    await useCase('me')();

    expect(syncHistory.calls, 1);
  });

  test('未サインインなら同期しない (サインインの再試行もしない)', () async {
    await useCase(null)();

    expect(syncHistory.calls, 0);
  });

  test('同期に失敗しても投げない (手元の履歴だけを表示する)', () async {
    syncHistory.error = Exception('offline');

    await expectLater(useCase('me')(), completes);
  });
}
