// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$targetHash() => r'f59499fa7657e53b6fda32d8fd313d76c36e7cd3';

/// 目的地を取得するプロバイダー
///
/// Copied from [target].
@ProviderFor(target)
final targetProvider = AutoDisposeProvider<LocationPoint?>.internal(
  target,
  name: r'targetProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$targetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TargetRef = AutoDisposeProviderRef<LocationPoint?>;
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
String _$midpointInfoListHash() => r'ab0f7d48ee5fea7c9347a1a074747e0aeea19dae';

/// 中間地点のリストを取得するプロバイダー
///
/// Copied from [midpointInfoList].
@ProviderFor(midpointInfoList)
final midpointInfoListProvider = AutoDisposeProvider<List<MidPoint>?>.internal(
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
typedef MidpointInfoListRef = AutoDisposeProviderRef<List<MidPoint>?>;
String _$missionControllerHash() => r'db9961ea105c57a7fa2e7cd4c5ae0b31d64bb68b';

/// ミッション情報を管理するコントローラー
///
/// Copied from [MissionController].
@ProviderFor(MissionController)
final missionControllerProvider =
    AutoDisposeAsyncNotifierProvider<MissionController, LocationModel>.internal(
  MissionController.new,
  name: r'missionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$missionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MissionController = AutoDisposeAsyncNotifier<LocationModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
