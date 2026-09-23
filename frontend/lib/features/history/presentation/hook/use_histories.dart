import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';

/// 履歴一覧 (完了日時の新しい順) を取得するカスタムフック
///
/// Riverpod の AsyncValue を返す。loading / error / data は when で分岐できる。
/// 開いたときに [historySyncProvider] の同期 (協力プレイの履歴など) を行い、終わったら読み直す。
AsyncValue<List<MissionHistory>> useHistories(WidgetRef ref) {
  final getHistories = ref.read(getMissionHistoriesUseCaseProvider);
  final isSynced = !ref.watch(historySyncProvider).isLoading;
  final future = useMemoized(getHistories.call, [isSynced]);
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
