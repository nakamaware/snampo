import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';

/// アプリ全体で動かす協力プレイの裏方
///
/// - 起動時: 匿名サインイン (失敗してもユーザーには見せない)、サムネの再送、未確定の履歴の同期
/// - フォアグラウンドに復帰したとき: サインインの再試行、サムネの再送
/// - ネットワークが復帰したとき: サムネの再送
///
/// 定期的なポーリングはしない。
void useCoopBackgroundSync(WidgetRef ref) {
  useEffect(() {
    Future<void> run({required bool syncHistory}) async {
      try {
        await ref.read(coopAuthServiceProvider).ensureSignedIn();
        await ref.read(retryThumbUploadsUseCaseProvider)();
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
        unawaited(run(syncHistory: false));
      }
    });
    return () {
      lifecycle.dispose();
      unawaited(connectivity.cancel());
    };
  }, const []);
}
