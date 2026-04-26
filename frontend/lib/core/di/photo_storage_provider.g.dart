// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 写真ストレージのプロバイダー

@ProviderFor(photoStorage)
final photoStorageProvider = PhotoStorageProvider._();

/// 写真ストレージのプロバイダー

final class PhotoStorageProvider
    extends $FunctionalProvider<IPhotoStorage, IPhotoStorage, IPhotoStorage>
    with $Provider<IPhotoStorage> {
  /// 写真ストレージのプロバイダー
  PhotoStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoStorageHash();

  @$internal
  @override
  $ProviderElement<IPhotoStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IPhotoStorage create(Ref ref) {
    return photoStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IPhotoStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IPhotoStorage>(value),
    );
  }
}

String _$photoStorageHash() => r'9740c5e7802997d76becf6e502af09f63bc88dda';
