// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ミッション情報を管理するストア

@ProviderFor(MissionStoreNotifier)
final missionStoreProvider = MissionStoreNotifierFamily._();

/// ミッション情報を管理するストア
final class MissionStoreNotifierProvider
    extends $AsyncNotifierProvider<MissionStoreNotifier, MissionEntity> {
  /// ミッション情報を管理するストア
  MissionStoreNotifierProvider._({
    required MissionStoreNotifierFamily super.from,
    required MissionStoreParams super.argument,
  }) : super(
         retry: null,
         name: r'missionStoreProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$missionStoreNotifierHash();

  @override
  String toString() {
    return r'missionStoreProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MissionStoreNotifier create() => MissionStoreNotifier();

  @override
  bool operator ==(Object other) {
    return other is MissionStoreNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$missionStoreNotifierHash() =>
    r'6b60eb8cfe26ee136585e8cbd38a7b1c5cdaa54b';

/// ミッション情報を管理するストア

final class MissionStoreNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MissionStoreNotifier,
          AsyncValue<MissionEntity>,
          MissionEntity,
          FutureOr<MissionEntity>,
          MissionStoreParams
        > {
  MissionStoreNotifierFamily._()
    : super(
        retry: null,
        name: r'missionStoreProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ミッション情報を管理するストア

  MissionStoreNotifierProvider call(MissionStoreParams params) =>
      MissionStoreNotifierProvider._(argument: params, from: this);

  @override
  String toString() => r'missionStoreProvider';
}

/// ミッション情報を管理するストア

abstract class _$MissionStoreNotifier extends $AsyncNotifier<MissionEntity> {
  late final _$args = ref.$arg as MissionStoreParams;
  MissionStoreParams get params => _$args;

  FutureOr<MissionEntity> build(MissionStoreParams params);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MissionEntity>, MissionEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MissionEntity>, MissionEntity>,
              AsyncValue<MissionEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
