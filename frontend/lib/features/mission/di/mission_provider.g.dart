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

/// 現在位置を取得するプロバイダー

@ProviderFor(currentPosition)
final currentPositionProvider = CurrentPositionProvider._();

/// 現在位置を取得するプロバイダー

final class CurrentPositionProvider
    extends
        $FunctionalProvider<
          AsyncValue<Coordinate>,
          Coordinate,
          FutureOr<Coordinate>
        >
    with $FutureModifier<Coordinate>, $FutureProvider<Coordinate> {
  /// 現在位置を取得するプロバイダー
  CurrentPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPositionHash();

  @$internal
  @override
  $FutureProviderElement<Coordinate> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Coordinate> create(Ref ref) {
    return currentPosition(ref);
  }
}

String _$currentPositionHash() => r'344c8e9924e9512ec45f91ba979e456bf162fc6b';

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

/// ランダムモードでミッション情報を取得するユースケースのプロバイダー

@ProviderFor(createRandomMissionUseCase)
final createRandomMissionUseCaseProvider =
    CreateRandomMissionUseCaseProvider._();

/// ランダムモードでミッション情報を取得するユースケースのプロバイダー

final class CreateRandomMissionUseCaseProvider
    extends
        $FunctionalProvider<
          CreateRandomMissionUseCase,
          CreateRandomMissionUseCase,
          CreateRandomMissionUseCase
        >
    with $Provider<CreateRandomMissionUseCase> {
  /// ランダムモードでミッション情報を取得するユースケースのプロバイダー
  CreateRandomMissionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRandomMissionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRandomMissionUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateRandomMissionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateRandomMissionUseCase create(Ref ref) {
    return createRandomMissionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateRandomMissionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateRandomMissionUseCase>(value),
    );
  }
}

String _$createRandomMissionUseCaseHash() =>
    r'ea243de9f3199b0730d287500fc8bee0c8a811a2';

/// 目的地指定モードでミッション情報を取得するユースケースのプロバイダー

@ProviderFor(createDestinationMissionUseCase)
final createDestinationMissionUseCaseProvider =
    CreateDestinationMissionUseCaseProvider._();

/// 目的地指定モードでミッション情報を取得するユースケースのプロバイダー

final class CreateDestinationMissionUseCaseProvider
    extends
        $FunctionalProvider<
          CreateDestinationMissionUseCase,
          CreateDestinationMissionUseCase,
          CreateDestinationMissionUseCase
        >
    with $Provider<CreateDestinationMissionUseCase> {
  /// 目的地指定モードでミッション情報を取得するユースケースのプロバイダー
  CreateDestinationMissionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createDestinationMissionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createDestinationMissionUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateDestinationMissionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateDestinationMissionUseCase create(Ref ref) {
    return createDestinationMissionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateDestinationMissionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateDestinationMissionUseCase>(
        value,
      ),
    );
  }
}

String _$createDestinationMissionUseCaseHash() =>
    r'8e771728c257f7cc349c74180fb5a47b03448dd4';
