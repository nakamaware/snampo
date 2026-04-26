import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';

/// 履歴一覧 (完了日時の新しい順) を取得するカスタムフック
///
/// Riverpod の AsyncValue を返す。loading / error / data は when で分岐できる。
AsyncValue<List<MissionHistory>> useHistories(WidgetRef ref) {
  final getHistories = ref.read(getMissionHistoriesUseCaseProvider);
  final future = useMemoized(getHistories.call, const []);
  final snapshot = useFuture(future);

  return switch (snapshot.connectionState) {
    ConnectionState.waiting => const AsyncValue.loading(),
    ConnectionState.done =>
      snapshot.hasError
          ? AsyncValue.error(
            snapshot.error!,
            snapshot.stackTrace ?? StackTrace.current,
          )
          : AsyncValue.data(snapshot.data!),
    _ => const AsyncValue.loading(),
  };
}
