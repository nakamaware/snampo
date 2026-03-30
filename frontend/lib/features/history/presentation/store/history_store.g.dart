// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 完了ミッションの履歴を SQLite に永続化する

@ProviderFor(HistoryStoreNotifier)
@JsonPersist()
final historyStoreProvider = HistoryStoreNotifierProvider._();

/// 完了ミッションの履歴を SQLite に永続化する
@JsonPersist()
final class HistoryStoreNotifierProvider
    extends
        $AsyncNotifierProvider<HistoryStoreNotifier, HistoryPersistedState> {
  /// 完了ミッションの履歴を SQLite に永続化する
  HistoryStoreNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyStoreNotifierHash();

  @$internal
  @override
  HistoryStoreNotifier create() => HistoryStoreNotifier();
}

String _$historyStoreNotifierHash() =>
    r'528132a2ade69c07ccd6496ee38b5effa03708ed';

/// 完了ミッションの履歴を SQLite に永続化する

@JsonPersist()
abstract class _$HistoryStoreNotifierBase
    extends $AsyncNotifier<HistoryPersistedState> {
  FutureOr<HistoryPersistedState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<HistoryPersistedState>, HistoryPersistedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HistoryPersistedState>,
                HistoryPersistedState
              >,
              AsyncValue<HistoryPersistedState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// **************************************************************************
// JsonGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
abstract class _$HistoryStoreNotifier extends _$HistoryStoreNotifierBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "HistoryStoreNotifier";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(HistoryPersistedState state)? encode,
    HistoryPersistedState Function(String encoded)? decode,
    StorageOptions options = const StorageOptions(),
  }) {
    return NotifierPersistX(this).persist<String, String>(
      storage,
      key: key ?? this.key,
      encode: encode ?? $jsonCodex.encode,
      decode:
          decode ??
          (encoded) {
            final e = $jsonCodex.decode(encoded);
            return HistoryPersistedState.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}
