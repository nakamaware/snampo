// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 位置情報サービスのプロバイダー

@ProviderFor(locationService)
final locationServiceProvider = LocationServiceProvider._();

/// 位置情報サービスのプロバイダー

final class LocationServiceProvider
    extends
        $FunctionalProvider<
          ILocationService,
          ILocationService,
          ILocationService
        >
    with $Provider<ILocationService> {
  /// 位置情報サービスのプロバイダー
  LocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  $ProviderElement<ILocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ILocationService create(Ref ref) {
    return locationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ILocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ILocationService>(value),
    );
  }
}

String _$locationServiceHash() => r'dd6fb819a5b2471f9d6e687a739bbd7a66f973e4';

/// ミッションリポジトリのプロバイダー

@ProviderFor(missionRepository)
final missionRepositoryProvider = MissionRepositoryProvider._();

/// ミッションリポジトリのプロバイダー

final class MissionRepositoryProvider
    extends
        $FunctionalProvider<
          IMissionRepository,
          IMissionRepository,
          IMissionRepository
        >
    with $Provider<IMissionRepository> {
  /// ミッションリポジトリのプロバイダー
  MissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionRepositoryHash();

  @$internal
  @override
  $ProviderElement<IMissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IMissionRepository create(Ref ref) {
    return missionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IMissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IMissionRepository>(value),
    );
  }
}

String _$missionRepositoryHash() => r'5d3ffc6b9fdb5a9846ec98cb368d9408cba1e58a';

/// ミッション情報を取得するユースケースのプロバイダー

@ProviderFor(getMissionUseCase)
final getMissionUseCaseProvider = GetMissionUseCaseProvider._();

/// ミッション情報を取得するユースケースのプロバイダー

final class GetMissionUseCaseProvider
    extends
        $FunctionalProvider<
          GetMissionUseCase,
          GetMissionUseCase,
          GetMissionUseCase
        >
    with $Provider<GetMissionUseCase> {
  /// ミッション情報を取得するユースケースのプロバイダー
  GetMissionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMissionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMissionUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMissionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMissionUseCase create(Ref ref) {
    return getMissionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMissionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMissionUseCase>(value),
    );
  }
}

String _$getMissionUseCaseHash() => r'1fbf4b776fbce908d596e747160f6b7348849be5';
