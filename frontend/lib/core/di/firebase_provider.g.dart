// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Firebase の初期化 (成功したらアプリ全体で 1 回だけ)
///
/// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。
/// 失敗しても自動では再試行しない (再試行するのは決まったイベントのときだけ。
/// [firebaseSetupReaderProvider] を使う)。

@ProviderFor(firebaseSetup)
final firebaseSetupProvider = FirebaseSetupProvider._();

/// Firebase の初期化 (成功したらアプリ全体で 1 回だけ)
///
/// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。
/// 失敗しても自動では再試行しない (再試行するのは決まったイベントのときだけ。
/// [firebaseSetupReaderProvider] を使う)。

final class FirebaseSetupProvider
    extends
        $FunctionalProvider<
          AsyncValue<FirebaseSetup>,
          FirebaseSetup,
          FutureOr<FirebaseSetup>
        >
    with $FutureModifier<FirebaseSetup>, $FutureProvider<FirebaseSetup> {
  /// Firebase の初期化 (成功したらアプリ全体で 1 回だけ)
  ///
  /// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。
  /// 失敗しても自動では再試行しない (再試行するのは決まったイベントのときだけ。
  /// [firebaseSetupReaderProvider] を使う)。
  FirebaseSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
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

String _$firebaseSetupHash() => r'98d3cdca50adea897d0fc257a6e719251267b820';

/// Firebase の初期化を待つ ([FirebaseSetupReader])

@ProviderFor(firebaseSetupReader)
final firebaseSetupReaderProvider = FirebaseSetupReaderProvider._();

/// Firebase の初期化を待つ ([FirebaseSetupReader])

final class FirebaseSetupReaderProvider
    extends
        $FunctionalProvider<
          FirebaseSetupReader,
          FirebaseSetupReader,
          FirebaseSetupReader
        >
    with $Provider<FirebaseSetupReader> {
  /// Firebase の初期化を待つ ([FirebaseSetupReader])
  FirebaseSetupReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseSetupReaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseSetupReaderHash();

  @$internal
  @override
  $ProviderElement<FirebaseSetupReader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseSetupReader create(Ref ref) {
    return firebaseSetupReader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseSetupReader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseSetupReader>(value),
    );
  }
}

String _$firebaseSetupReaderHash() =>
    r'3b007cb0084d7c96de8ce08d295f41b77ac37490';

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
