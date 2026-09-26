import 'dart:developer';

import 'package:snampo/features/coop/application/usecase/get_coop_signed_in_uid_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_history_use_case.dart';

/// サインイン済みなら、未確定の協力プレイ履歴を同期する (履歴画面を開いたときに呼ぶ)
///
/// サインインの再試行はしない (未サインインなら同期しない)。オフラインや協力プレイを使えない
/// 端末では何もせず、手元の履歴だけを表示できるよう、失敗しても投げない。
class SyncCoopHistoryIfSignedInUseCase {
  /// [SyncCoopHistoryIfSignedInUseCase] を作成する
  SyncCoopHistoryIfSignedInUseCase({
    required GetCoopSignedInUidUseCase signedInUid,
    required SyncCoopHistoryUseCase syncHistory,
  }) : _signedInUid = signedInUid,
       _syncHistory = syncHistory;

  final GetCoopSignedInUidUseCase _signedInUid;
  final SyncCoopHistoryUseCase _syncHistory;

  /// 同期する
  Future<void> call() async {
    try {
      if (await _signedInUid() == null) {
        return;
      }
      await _syncHistory();
    } on Object catch (e) {
      log('協力プレイ履歴の同期をスキップした: $e', name: 'CoopHistorySync');
    }
  }
}
