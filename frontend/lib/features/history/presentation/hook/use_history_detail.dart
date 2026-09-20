import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';

/// 履歴 1 件を id で取得するカスタムフック
///
/// Riverpod の AsyncValue を返す。該当なしの場合は data が null。
AsyncValue<MissionHistory?> useHistoryDetail(WidgetRef ref, String recordId) {
  final getHistory = ref.read(getMissionHistoryUseCaseProvider);
  final future = useMemoized(() => getHistory.call(recordId), [recordId]);
  final snapshot = useFuture(future);

  return switch (snapshot.connectionState) {
    ConnectionState.waiting => const AsyncValue.loading(),
    ConnectionState.done =>
      snapshot.hasError
          ? AsyncValue.error(
            snapshot.error!,
            snapshot.stackTrace ?? StackTrace.current,
          )
          : AsyncValue.data(snapshot.data),
    _ => const AsyncValue.loading(),
  };
}
