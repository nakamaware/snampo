// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameSessionRepositoryHash() =>
    r'68fa04ac076b12eb331005296204eb230862078a';

/// ゲームセッションリポジトリのプロバイダー
///
/// Copied from [gameSessionRepository].
@ProviderFor(gameSessionRepository)
final gameSessionRepositoryProvider =
    AutoDisposeProvider<GameSessionRepository>.internal(
  gameSessionRepository,
  name: r'gameSessionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameSessionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameSessionRepositoryRef
    = AutoDisposeProviderRef<GameSessionRepository>;
String _$hasSavedSessionHash() => r'365fe3e310d27edcf909b4216ad93104b8414cba';

/// 中断中のゲームセッションがあるかをチェックするプロバイダー
///
/// Copied from [hasSavedSession].
@ProviderFor(hasSavedSession)
final hasSavedSessionProvider = AutoDisposeFutureProvider<bool>.internal(
  hasSavedSession,
  name: r'hasSavedSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasSavedSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasSavedSessionRef = AutoDisposeFutureProviderRef<bool>;
String _$savedSessionHash() => r'e8c459b3488204a79aad8b847b0ecfc4288619f4';

/// 保存されたゲームセッションを取得するプロバイダー
///
/// Copied from [savedSession].
@ProviderFor(savedSession)
final savedSessionProvider = AutoDisposeFutureProvider<GameSession?>.internal(
  savedSession,
  name: r'savedSessionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$savedSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavedSessionRef = AutoDisposeFutureProviderRef<GameSession?>;
String _$capturedPhotosControllerHash() =>
    r'd1afcae1c4eacef26ce40871935f77677871cb2e';

/// 撮影した写真を管理するコントローラー
///
/// Copied from [CapturedPhotosController].
@ProviderFor(CapturedPhotosController)
final capturedPhotosControllerProvider = AutoDisposeNotifierProvider<
    CapturedPhotosController, CapturedPhotos>.internal(
  CapturedPhotosController.new,
  name: r'capturedPhotosControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$capturedPhotosControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CapturedPhotosController = AutoDisposeNotifier<CapturedPhotos>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
