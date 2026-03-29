// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persisted_mission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー

@ProviderFor(PersistedMission)
@JsonPersist()
final persistedMissionProvider = PersistedMissionProvider._();

/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
@JsonPersist()
final class PersistedMissionProvider
    extends $AsyncNotifierProvider<PersistedMission, MissionEntity?> {
  /// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
  PersistedMissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'persistedMissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$persistedMissionHash();

  @$internal
  @override
  PersistedMission create() => PersistedMission();
}

String _$persistedMissionHash() => r'5ef1bca589230012e1941e31e62f08fc09bf40a8';

/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー

@JsonPersist()
abstract class _$PersistedMissionBase extends $AsyncNotifier<MissionEntity?> {
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
abstract class _$PersistedMission extends _$PersistedMissionBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "PersistedMission";
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
