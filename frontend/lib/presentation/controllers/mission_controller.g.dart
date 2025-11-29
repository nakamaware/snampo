// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$missionRepositoryHash() => r'80e9d4a76cf3aed6ab9abc876cdf3f1db179bfc1';

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
String _$targetHash() => r'cbed4ae546dc93c81528be5cace643c1ada5caf1';

/// 目的地を取得するプロバイダー
///
/// Copied from [target].
@ProviderFor(target)
final targetProvider = AutoDisposeProvider<LocationPointEntity?>.internal(
  target,
  name: r'targetProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$targetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TargetRef = AutoDisposeProviderRef<LocationPointEntity?>;
String _$routeHash() => r'3013a4b7583d23c637ec6381359a43a61cb70a51';

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
String _$midpointInfoListHash() => r'51594576cae51efb76d970c1e8c21cf8114ae385';

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
String _$missionControllerHash() => r'6aa3867711e7eb47be57e2211f08ee6783eaf5b7';

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
