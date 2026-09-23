import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';

/// 現在位置を取得するカスタムフック
///
/// AsyncValue を返します。
/// loading / error / data の状態を AsyncValue.when で扱えます。
AsyncValue<Coordinate> useCurrentPosition(WidgetRef ref) {
  final getCurrentPositionUseCase = ref.read(getCurrentPositionUseCaseProvider);
  final future = useMemoized(getCurrentPositionUseCase.call);
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
