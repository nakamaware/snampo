import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';

/// 履歴一覧 (完了日時の新しい順) を取得するカスタムフック
///
/// Riverpod の AsyncValue を返す。loading / error / data は when で分岐できる。
/// 開いたときに未確定の協力プレイ履歴を同期し、終わったら読み直す。
AsyncValue<List<MissionHistory>> useHistories(WidgetRef ref) {
  final getHistories = ref.read(getMissionHistoriesUseCaseProvider);
  final version = useState(0);
  useEffect(() {
    var disposed = false;
    Future(() async {
      try {
        // サインインの再試行はしない (未サインインなら同期しない)
        if (await ref.read(coopAuthServiceProvider).signedInUid() == null) {
          return;
        }
        await ref.read(syncCoopHistoryUseCaseProvider)();
      } on Object catch (e) {
        // オフラインや協力プレイを使えない端末では、手元の履歴だけを表示する
        log('協力プレイ履歴の同期をスキップした: $e', name: 'useHistories');
        return;
      }
      if (!disposed) {
        version.value++;
      }
    });
    return () => disposed = true;
  }, const []);
  final future = useMemoized(getHistories.call, [version.value]);
  final snapshot = useFuture(future);

  if (snapshot.hasData) {
    return AsyncValue.data(snapshot.data!);
  }
  return switch (snapshot.connectionState) {
    ConnectionState.done when snapshot.hasError => AsyncValue.error(
      snapshot.error!,
      snapshot.stackTrace ?? StackTrace.current,
    ),
    _ => const AsyncValue.loading(),
  };
}
