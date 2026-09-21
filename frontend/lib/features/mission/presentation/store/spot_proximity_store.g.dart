// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot_proximity_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// スポット離脱監視と通知制御を行うストア

@ProviderFor(SpotProximityStoreNotifier)
final spotProximityStoreProvider = SpotProximityStoreNotifierProvider._();

/// スポット離脱監視と通知制御を行うストア
final class SpotProximityStoreNotifierProvider
    extends $NotifierProvider<SpotProximityStoreNotifier, SpotProximityState?> {
  /// スポット離脱監視と通知制御を行うストア
  SpotProximityStoreNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spotProximityStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spotProximityStoreNotifierHash();

  @$internal
  @override
  SpotProximityStoreNotifier create() => SpotProximityStoreNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpotProximityState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpotProximityState?>(value),
    );
  }
}

String _$spotProximityStoreNotifierHash() =>
    r'fdf2f8f4c95fee06a574cd52e06c3f442bdf5c9f';

/// スポット離脱監視と通知制御を行うストア

abstract class _$SpotProximityStoreNotifier
    extends $Notifier<SpotProximityState?> {
  SpotProximityState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SpotProximityState?, SpotProximityState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SpotProximityState?, SpotProximityState?>,
              SpotProximityState?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
