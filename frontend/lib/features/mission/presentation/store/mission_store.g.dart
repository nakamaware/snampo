// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ミッションリポジトリのプロバイダー

@ProviderFor(missionRepository)
final missionRepositoryProvider = MissionRepositoryProvider._();

/// ミッションリポジトリのプロバイダー

final class MissionRepositoryProvider extends $FunctionalProvider<
    MissionRepository,
    MissionRepository,
    MissionRepository> with $Provider<MissionRepository> {
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
  $ProviderElement<MissionRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MissionRepository create(Ref ref) {
    return missionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MissionRepository>(value),
    );
  }
}

String _$missionRepositoryHash() => r'2392a60bfd7b3e1c8bf62814038ee5f2df98a180';

/// 現在地を取得するユースケースのプロバイダー

@ProviderFor(getCurrentLocationUseCase)
final getCurrentLocationUseCaseProvider = GetCurrentLocationUseCaseProvider._();

/// 現在地を取得するユースケースのプロバイダー

final class GetCurrentLocationUseCaseProvider extends $FunctionalProvider<
    GetCurrentLocationUseCase,
    GetCurrentLocationUseCase,
    GetCurrentLocationUseCase> with $Provider<GetCurrentLocationUseCase> {
  /// 現在地を取得するユースケースのプロバイダー
  GetCurrentLocationUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getCurrentLocationUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCurrentLocationUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentLocationUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetCurrentLocationUseCase create(Ref ref) {
    return getCurrentLocationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentLocationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentLocationUseCase>(value),
    );
  }
}

String _$getCurrentLocationUseCaseHash() =>
    r'1b46d72dd802296b8ce7b3f16ac4daac57905cc1';

/// ミッション情報を取得するユースケースのプロバイダー

@ProviderFor(getMissionUseCase)
final getMissionUseCaseProvider = GetMissionUseCaseProvider._();

/// ミッション情報を取得するユースケースのプロバイダー

final class GetMissionUseCaseProvider extends $FunctionalProvider<
    GetMissionUseCase,
    GetMissionUseCase,
    GetMissionUseCase> with $Provider<GetMissionUseCase> {
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
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

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

String _$getMissionUseCaseHash() => r'7b18f274819f9f458415aa5c5156604e70ec641b';

/// ミッション情報を管理するストア

@ProviderFor(MissionNotifier)
final missionProvider = MissionNotifierProvider._();

/// ミッション情報を管理するストア
final class MissionNotifierProvider
    extends $AsyncNotifierProvider<MissionNotifier, LocationEntity> {
  /// ミッション情報を管理するストア
  MissionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'missionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$missionNotifierHash();

  @$internal
  @override
  MissionNotifier create() => MissionNotifier();
}

String _$missionNotifierHash() => r'1610d90005d51228d033c67e08315606d4acc54b';

/// ミッション情報を管理するストア

abstract class _$MissionNotifier extends $AsyncNotifier<LocationEntity> {
  FutureOr<LocationEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LocationEntity>, LocationEntity>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<LocationEntity>, LocationEntity>,
        AsyncValue<LocationEntity>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// 目的地を取得するプロバイダー

@ProviderFor(target)
final targetProvider = TargetProvider._();

/// 目的地を取得するプロバイダー

final class TargetProvider extends $FunctionalProvider<MidPointEntity?,
    MidPointEntity?, MidPointEntity?> with $Provider<MidPointEntity?> {
  /// 目的地を取得するプロバイダー
  TargetProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'targetProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$targetHash();

  @$internal
  @override
  $ProviderElement<MidPointEntity?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MidPointEntity? create(Ref ref) {
    return target(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MidPointEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MidPointEntity?>(value),
    );
  }
}

String _$targetHash() => r'3846633866fe443b5960ebafaa7e4e5a1f74d2c2';

/// ルートのポリライン文字列を取得するプロバイダー

@ProviderFor(route)
final routeProvider = RouteProvider._();

/// ルートのポリライン文字列を取得するプロバイダー

final class RouteProvider extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// ルートのポリライン文字列を取得するプロバイダー
  RouteProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'routeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$routeHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return route(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$routeHash() => r'166b7fe15f3010294955f9fa3143ea182b613da6';

/// 中間地点のリストを取得するプロバイダー

@ProviderFor(midpointInfoList)
final midpointInfoListProvider = MidpointInfoListProvider._();

/// 中間地点のリストを取得するプロバイダー

final class MidpointInfoListProvider extends $FunctionalProvider<
    List<MidPointEntity>?,
    List<MidPointEntity>?,
    List<MidPointEntity>?> with $Provider<List<MidPointEntity>?> {
  /// 中間地点のリストを取得するプロバイダー
  MidpointInfoListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'midpointInfoListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$midpointInfoListHash();

  @$internal
  @override
  $ProviderElement<List<MidPointEntity>?> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<MidPointEntity>? create(Ref ref) {
    return midpointInfoList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MidPointEntity>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MidPointEntity>?>(value),
    );
  }
}

String _$midpointInfoListHash() => r'bd03c204e42e81369e0ba38cf6f12a0239877555';
