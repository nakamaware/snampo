// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ミッション情報を管理するストア

@ProviderFor(MissionNotifier)
final missionProvider = MissionNotifierFamily._();

/// ミッション情報を管理するストア
final class MissionNotifierProvider
    extends $AsyncNotifierProvider<MissionNotifier, MissionEntity> {
  /// ミッション情報を管理するストア
  MissionNotifierProvider._(
      {required MissionNotifierFamily super.from,
      required Radius super.argument})
      : super(
          retry: null,
          name: r'missionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$missionNotifierHash();

  @override
  String toString() {
    return r'missionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MissionNotifier create() => MissionNotifier();

  @override
  bool operator ==(Object other) {
    return other is MissionNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$missionNotifierHash() => r'763b57933bc9c58c6a36c7c16b5f2d36ed2b651e';

/// ミッション情報を管理するストア

final class MissionNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MissionNotifier, AsyncValue<MissionEntity>,
            MissionEntity, FutureOr<MissionEntity>, Radius> {
  MissionNotifierFamily._()
      : super(
          retry: null,
          name: r'missionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// ミッション情報を管理するストア

  MissionNotifierProvider call(
    Radius radius,
  ) =>
      MissionNotifierProvider._(argument: radius, from: this);

  @override
  String toString() => r'missionProvider';
}

/// ミッション情報を管理するストア

abstract class _$MissionNotifier extends $AsyncNotifier<MissionEntity> {
  late final _$args = ref.$arg as Radius;
  Radius get radius => _$args;

  FutureOr<MissionEntity> build(
    Radius radius,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MissionEntity>, MissionEntity>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<MissionEntity>, MissionEntity>,
        AsyncValue<MissionEntity>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
