// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_progress_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ミッション進捗を管理するストア
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。

@ProviderFor(MissionProgressStoreNotifier)
@JsonPersist()
final missionProgressStoreProvider = MissionProgressStoreNotifierFamily._();

/// ミッション進捗を管理するストア
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。
@JsonPersist()
final class MissionProgressStoreNotifierProvider
    extends
        $AsyncNotifierProvider<
          MissionProgressStoreNotifier,
          MissionProgressEntity?
        > {
  /// ミッション進捗を管理するストア
  ///
  /// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。
  MissionProgressStoreNotifierProvider._({
    required MissionProgressStoreNotifierFamily super.from,
    required MissionSessionKind super.argument,
  }) : super(
         retry: null,
         name: r'missionProgressStoreProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$missionProgressStoreNotifierHash();

  @override
  String toString() {
    return r'missionProgressStoreProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MissionProgressStoreNotifier create() => MissionProgressStoreNotifier();

  @override
  bool operator ==(Object other) {
    return other is MissionProgressStoreNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$missionProgressStoreNotifierHash() =>
    r'c7154cf468f6be7efc0a2245ea4e6b69a90cb98c';

/// ミッション進捗を管理するストア
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。

@JsonPersist()
final class MissionProgressStoreNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MissionProgressStoreNotifier,
          AsyncValue<MissionProgressEntity?>,
          MissionProgressEntity?,
          FutureOr<MissionProgressEntity?>,
          MissionSessionKind
        > {
  MissionProgressStoreNotifierFamily._()
    : super(
        retry: null,
        name: r'missionProgressStoreProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// ミッション進捗を管理するストア
  ///
  /// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。

  @JsonPersist()
  MissionProgressStoreNotifierProvider call(MissionSessionKind kind) =>
      MissionProgressStoreNotifierProvider._(argument: kind, from: this);

  @override
  String toString() => r'missionProgressStoreProvider';
}

/// ミッション進捗を管理するストア
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。

@JsonPersist()
abstract class _$MissionProgressStoreNotifierBase
    extends $AsyncNotifier<MissionProgressEntity?> {
  late final _$args = ref.$arg as MissionSessionKind;
  MissionSessionKind get kind => _$args;

  FutureOr<MissionProgressEntity?> build(MissionSessionKind kind);
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
    element.handleCreate(ref, () => build(_$args));
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
    late final args = kind;
    late final resolvedKey = 'MissionProgressStoreNotifier($args)';

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
