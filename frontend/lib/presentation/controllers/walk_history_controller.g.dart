// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walkHistoryRepositoryHash() =>
    r'575dc4a2e4ab6d4d8ef89dbf0ac00080261352a8';

/// 散歩履歴リポジトリのプロバイダー
///
/// Copied from [walkHistoryRepository].
@ProviderFor(walkHistoryRepository)
final walkHistoryRepositoryProvider =
    AutoDisposeProvider<WalkHistoryRepository>.internal(
  walkHistoryRepository,
  name: r'walkHistoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walkHistoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalkHistoryRepositoryRef
    = AutoDisposeProviderRef<WalkHistoryRepository>;
String _$walkHistoryControllerHash() =>
    r'c170ccabb015a9c478016b388f981adb564d4582';

/// 散歩履歴を管理するコントローラー
///
/// Copied from [WalkHistoryController].
@ProviderFor(WalkHistoryController)
final walkHistoryControllerProvider = AutoDisposeAsyncNotifierProvider<
    WalkHistoryController, List<WalkHistory>>.internal(
  WalkHistoryController.new,
  name: r'walkHistoryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walkHistoryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WalkHistoryController = AutoDisposeAsyncNotifier<List<WalkHistory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
