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
String _$hasSavedSessionHash() => r'2b55c6188a24cb26c34064773aeffe4541de25e5';

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
String _$gameSessionControllerHash() =>
    r'1393d2ee7bd040093c06779acbce93ad59876621';

/// ゲームセッションと写真を統合管理するコントローラー
///
/// Copied from [GameSessionController].
@ProviderFor(GameSessionController)
final gameSessionControllerProvider = AutoDisposeAsyncNotifierProvider<
    GameSessionController, GameSession?>.internal(
  GameSessionController.new,
  name: r'gameSessionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameSessionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GameSessionController = AutoDisposeAsyncNotifier<GameSession?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
