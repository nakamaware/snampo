// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$missionRepositoryHash() => r'2392a60bfd7b3e1c8bf62814038ee5f2df98a180';

/// ミッションリポジトリのプロバイダー
///
/// Copied from [missionRepository].
@ProviderFor(missionRepository)
final missionRepositoryProvider =
    AutoDisposeProvider<MissionRepository>.internal(
  missionRepository,
  name: r'missionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$missionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MissionRepositoryRef = AutoDisposeProviderRef<MissionRepository>;
String _$getCurrentLocationUseCaseHash() =>
    r'1b46d72dd802296b8ce7b3f16ac4daac57905cc1';

/// 現在地を取得するユースケースのプロバイダー
///
/// Copied from [getCurrentLocationUseCase].
@ProviderFor(getCurrentLocationUseCase)
final getCurrentLocationUseCaseProvider =
    AutoDisposeProvider<GetCurrentLocationUseCase>.internal(
  getCurrentLocationUseCase,
  name: r'getCurrentLocationUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCurrentLocationUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetCurrentLocationUseCaseRef
    = AutoDisposeProviderRef<GetCurrentLocationUseCase>;
String _$getMissionUseCaseHash() => r'7b18f274819f9f458415aa5c5156604e70ec641b';

/// ミッション情報を取得するユースケースのプロバイダー
///
/// Copied from [getMissionUseCase].
@ProviderFor(getMissionUseCase)
final getMissionUseCaseProvider =
    AutoDisposeProvider<GetMissionUseCase>.internal(
  getMissionUseCase,
  name: r'getMissionUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getMissionUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetMissionUseCaseRef = AutoDisposeProviderRef<GetMissionUseCase>;
String _$targetHash() => r'3846633866fe443b5960ebafaa7e4e5a1f74d2c2';

/// 目的地を取得するプロバイダー
///
/// Copied from [target].
@ProviderFor(target)
final targetProvider = AutoDisposeProvider<MidPointEntity?>.internal(
  target,
  name: r'targetProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$targetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TargetRef = AutoDisposeProviderRef<MidPointEntity?>;
String _$routeHash() => r'166b7fe15f3010294955f9fa3143ea182b613da6';

/// ルートのポリライン文字列を取得するプロバイダー
///
/// Copied from [route].
@ProviderFor(route)
final routeProvider = AutoDisposeProvider<String?>.internal(
  route,
  name: r'routeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouteRef = AutoDisposeProviderRef<String?>;
String _$midpointInfoListHash() => r'bd03c204e42e81369e0ba38cf6f12a0239877555';

/// 中間地点のリストを取得するプロバイダー
///
/// Copied from [midpointInfoList].
@ProviderFor(midpointInfoList)
final midpointInfoListProvider =
    AutoDisposeProvider<List<MidPointEntity>?>.internal(
  midpointInfoList,
  name: r'midpointInfoListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$midpointInfoListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MidpointInfoListRef = AutoDisposeProviderRef<List<MidPointEntity>?>;
String _$missionNotifierHash() => r'1610d90005d51228d033c67e08315606d4acc54b';

/// ミッション情報を管理するストア
///
/// Copied from [MissionNotifier].
@ProviderFor(MissionNotifier)
final missionNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MissionNotifier, LocationEntity>.internal(
  MissionNotifier.new,
  name: r'missionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$missionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MissionNotifier = AutoDisposeAsyncNotifier<LocationEntity>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
