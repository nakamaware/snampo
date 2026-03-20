// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ミッション情報を取得するストア（ランダム / 目的地 / 再開）

@ProviderFor(MissionStoreNotifier)
final missionStoreProvider = MissionStoreNotifierFamily._();

/// ミッション情報を取得するストア（ランダム / 目的地 / 再開）
final class MissionStoreNotifierProvider
    extends $AsyncNotifierProvider<MissionStoreNotifier, MissionEntity> {
  /// ミッション情報を取得するストア（ランダム / 目的地 / 再開）
  MissionStoreNotifierProvider._({
    required MissionStoreNotifierFamily super.from,
    required MissionStoreParams super.argument,
  }) : super(
         retry: _noRetry,
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
    r'7f0a54ae7ef404e8fd5624c45e2792f844f021d9';

/// ミッション情報を取得するストア（ランダム / 目的地 / 再開）

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
        retry: _noRetry,
        name: r'missionStoreProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ミッション情報を取得するストア（ランダム / 目的地 / 再開）

  MissionStoreNotifierProvider call(MissionStoreParams params) =>
      MissionStoreNotifierProvider._(argument: params, from: this);

  @override
  String toString() => r'missionStoreProvider';
}

/// ミッション情報を取得するストア（ランダム / 目的地 / 再開）

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
