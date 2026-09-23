import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/app_scaffold_messenger.dart';
import 'package:snampo/features/coop/application/usecase/retry_pending_clears_use_case.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/presentation/util/pending_clear_failure_message.dart';

/// アプリ全体で動かす協力プレイの裏方
///
/// - 起動時: 匿名サインイン (失敗してもユーザーには見せない)、発見の送り直し、未確定の履歴の同期
/// - フォアグラウンドに復帰したとき: サインインの再試行、発見の送り直し
/// - ネットワークが復帰したとき: 発見の送り直し (サインイン済みのときだけ)
///
/// 送り直しても共有できなかった発見 (先に他の人が発見していたなど) は、エラーとして表示する。
///
/// サインインを再試行するのは、起動時のほかは「みんなで」を押したときと
/// フォアグラウンドに復帰したときだけ。定期的なポーリングはしない。
void useCoopBackgroundSync(WidgetRef ref) {
  useEffect(() {
    Future<void> run({required bool syncHistory, bool signIn = true}) async {
      try {
        if (signIn) {
          await ref.read(coopAuthServiceProvider).ensureSignedIn();
        }
        final result = await ref.read(retryPendingClearsUseCaseProvider)();
        _showFailures(result.failures);
        if (syncHistory) {
          await ref.read(syncCoopHistoryUseCaseProvider)();
        }
      } on Object catch (e) {
        log('協力プレイの裏方の処理をスキップした: $e', name: 'CoopBackgroundSync');
      }
    }

    unawaited(run(syncHistory: true));
    final lifecycle = AppLifecycleListener(
      onResume: () => unawaited(run(syncHistory: false)),
    );
    final connectivity = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        unawaited(run(syncHistory: false, signIn: false));
      }
    });
    return () {
      lifecycle.dispose();
      unawaited(connectivity.cancel());
    };
  }, const []);
}

void _showFailures(List<PendingClearFailure> failures) {
  if (failures.isEmpty) {
    return;
  }
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(failures.map(pendingClearFailureMessage).join('\n')),
      duration: const Duration(seconds: 8),
    ),
  );
}
