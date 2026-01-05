// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$missionRepositoryHash() => r'2beab0425eaaf019920d04f9035648b852cf0373';

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
String _$targetHash() => r'2e13867a224b52d3aa01d574ffb95a800e8304fc';

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
String _$routeHash() => r'46e3dc8ae435a236efc8d6d82f64b80bc418704c';

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
String _$midpointInfoListHash() => r'cbfe00b338652a14efe17d8f7c09ab7cc9396689';

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
String _$missionControllerHash() => r'f12f6fc69df8136d71fb7d6d9a60efea1a8f74d5';

/// ミッション情報を管理するコントローラー
///
/// Copied from [MissionController].
@ProviderFor(MissionController)
final missionControllerProvider = AutoDisposeAsyncNotifierProvider<
    MissionController, LocationEntity>.internal(
  MissionController.new,
  name: r'missionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$missionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MissionController = AutoDisposeAsyncNotifier<LocationEntity>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
