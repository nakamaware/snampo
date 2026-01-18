// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CameraStore)
final cameraStoreProvider = CameraStoreProvider._();

final class CameraStoreProvider
    extends $NotifierProvider<CameraStore, Map<int, String>> {
  CameraStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'CameraStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraStoreHash();

  @$internal
  @override
  CameraStore create() => CameraStore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, String>>(value),
    );
  }
}

String _$cameraStoreHash() => r'816cf5f03e4d66e2f7ea8a32e3d0f3fa93e7fef7';

abstract class _$CameraStore extends $Notifier<Map<int, String>> {
  Map<int, String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<int, String>, Map<int, String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<int, String>, Map<int, String>>,
              Map<int, String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
