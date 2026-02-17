// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ミッション情報を管理するストア

@ProviderFor(MissionStoreNotifier)
@JsonPersist()
final missionStoreProvider = MissionStoreNotifierProvider._();

/// ミッション情報を管理するストア
@JsonPersist()
final class MissionStoreNotifierProvider
    extends $AsyncNotifierProvider<MissionStoreNotifier, MissionEntity?> {
  /// ミッション情報を管理するストア
  MissionStoreNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionStoreNotifierHash();

  @$internal
  @override
  MissionStoreNotifier create() => MissionStoreNotifier();
}

String _$missionStoreNotifierHash() =>
    r'b9433848fa55864245155c8b07504d83dfad66ad';

/// ミッション情報を管理するストア

@JsonPersist()
abstract class _$MissionStoreNotifierBase
    extends $AsyncNotifier<MissionEntity?> {
  FutureOr<MissionEntity?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MissionEntity?>, MissionEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MissionEntity?>, MissionEntity?>,
              AsyncValue<MissionEntity?>,
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
abstract class _$MissionStoreNotifier extends _$MissionStoreNotifierBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "MissionStoreNotifier";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(MissionEntity? state)? encode,
    MissionEntity? Function(String encoded)? decode,
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
                : MissionEntity?.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}
