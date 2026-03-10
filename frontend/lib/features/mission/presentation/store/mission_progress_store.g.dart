// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_progress_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ミッション進捗を管理するストア

@ProviderFor(MissionProgressStoreNotifier)
@JsonPersist()
final missionProgressStoreProvider = MissionProgressStoreNotifierProvider._();

/// ミッション進捗を管理するストア
@JsonPersist()
final class MissionProgressStoreNotifierProvider
    extends
        $AsyncNotifierProvider<
          MissionProgressStoreNotifier,
          MissionProgressEntity?
        > {
  /// ミッション進捗を管理するストア
  MissionProgressStoreNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionProgressStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionProgressStoreNotifierHash();

  @$internal
  @override
  MissionProgressStoreNotifier create() => MissionProgressStoreNotifier();
}

String _$missionProgressStoreNotifierHash() =>
    r'cee709647674c3ef055c30e00ee527d276aa9e68';

/// ミッション進捗を管理するストア

@JsonPersist()
abstract class _$MissionProgressStoreNotifierBase
    extends $AsyncNotifier<MissionProgressEntity?> {
  FutureOr<MissionProgressEntity?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<MissionProgressEntity?>, MissionProgressEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<MissionProgressEntity?>,
                MissionProgressEntity?
              >,
              AsyncValue<MissionProgressEntity?>,
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
abstract class _$MissionProgressStoreNotifier
    extends _$MissionProgressStoreNotifierBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "MissionProgressStoreNotifier";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(MissionProgressEntity? state)? encode,
    MissionProgressEntity? Function(String encoded)? decode,
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
            return e == null
                ? null
                : MissionProgressEntity?.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}
