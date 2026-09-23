// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persisted_mission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。

@ProviderFor(PersistedMission)
@JsonPersist()
final persistedMissionProvider = PersistedMissionFamily._();

/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。
@JsonPersist()
final class PersistedMissionProvider
    extends $AsyncNotifierProvider<PersistedMission, MissionEntity?> {
  /// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
  ///
  /// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。
  PersistedMissionProvider._({
    required PersistedMissionFamily super.from,
    required MissionSessionKind super.argument,
  }) : super(
         retry: null,
         name: r'persistedMissionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$persistedMissionHash();

  @override
  String toString() {
    return r'persistedMissionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PersistedMission create() => PersistedMission();

  @override
  bool operator ==(Object other) {
    return other is PersistedMissionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$persistedMissionHash() => r'8e82f9f45dcd7ac817536dfd102e59e9a7b721a5';

/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。

@JsonPersist()
final class PersistedMissionFamily extends $Family
    with
        $ClassFamilyOverride<
          PersistedMission,
          AsyncValue<MissionEntity?>,
          MissionEntity?,
          FutureOr<MissionEntity?>,
          MissionSessionKind
        > {
  PersistedMissionFamily._()
    : super(
        retry: null,
        name: r'persistedMissionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
  ///
  /// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。

  @JsonPersist()
  PersistedMissionProvider call(MissionSessionKind kind) =>
      PersistedMissionProvider._(argument: kind, from: this);

  @override
  String toString() => r'persistedMissionProvider';
}

/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。

@JsonPersist()
abstract class _$PersistedMissionBase extends $AsyncNotifier<MissionEntity?> {
  late final _$args = ref.$arg as MissionSessionKind;
  MissionSessionKind get kind => _$args;

  FutureOr<MissionEntity?> build(MissionSessionKind kind);
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
    element.handleCreate(ref, () => build(_$args));
  }
}

// **************************************************************************
// JsonGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
abstract class _$PersistedMission extends _$PersistedMissionBase {
  /// The default key used by [persist].
  String get key {
    late final args = kind;
    late final resolvedKey = 'PersistedMission($args)';

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
