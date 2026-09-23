// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Firebase の初期化 (アプリ全体で 1 回だけ)
///
/// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。

@ProviderFor(firebaseSetup)
final firebaseSetupProvider = FirebaseSetupProvider._();

/// Firebase の初期化 (アプリ全体で 1 回だけ)
///
/// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。

final class FirebaseSetupProvider
    extends
        $FunctionalProvider<
          AsyncValue<FirebaseSetup>,
          FirebaseSetup,
          FutureOr<FirebaseSetup>
        >
    with $FutureModifier<FirebaseSetup>, $FutureProvider<FirebaseSetup> {
  /// Firebase の初期化 (アプリ全体で 1 回だけ)
  ///
  /// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。
  FirebaseSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseSetupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseSetupHash();

  @$internal
  @override
  $FutureProviderElement<FirebaseSetup> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FirebaseSetup> create(Ref ref) {
    return firebaseSetup(ref);
  }
}

String _$firebaseSetupHash() => r'436bb0cff48ed062972870ccc7e79c8b026ef4e2';

/// App Check のデバッグトークン (dev ビルドで設定画面に表示する)

@ProviderFor(appCheckDebugToken)
final appCheckDebugTokenProvider = AppCheckDebugTokenProvider._();

/// App Check のデバッグトークン (dev ビルドで設定画面に表示する)

final class AppCheckDebugTokenProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// App Check のデバッグトークン (dev ビルドで設定画面に表示する)
  AppCheckDebugTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appCheckDebugTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appCheckDebugTokenHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appCheckDebugToken(ref);
  }
}

String _$appCheckDebugTokenHash() =>
    r'f5ed60fdb0461ae742d8355008512b8c42a93fb7';
