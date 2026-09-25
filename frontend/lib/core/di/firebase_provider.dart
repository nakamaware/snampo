import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/firebase/app_check_debug_token.dart';
import 'package:snampo/core/firebase/firebase_initializer.dart';

part 'firebase_provider.g.dart';

/// Firebase の初期化 (成功したらアプリ全体で 1 回だけ)
///
/// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。
/// 失敗しても自動では再試行しない (再試行するのは決まったイベントのときだけ。
/// [firebaseSetupReaderProvider] を使う)。
@Riverpod(keepAlive: true, retry: _noRetry)
Future<FirebaseSetup> firebaseSetup(Ref ref) => initializeFirebase();

Duration? _noRetry(int retryCount, Object error) => null;

/// Firebase の初期化を待つ関数
///
/// [retryIfFailed] が true で、前の初期化に失敗していれば、初期化し直す
/// (「みんなで」を押したときや「再試行」など)。
typedef FirebaseSetupReader =
    Future<FirebaseSetup> Function({required bool retryIfFailed});

/// Firebase の初期化を待つ ([FirebaseSetupReader])
@Riverpod(keepAlive: true)
FirebaseSetupReader firebaseSetupReader(Ref ref) => ({required retryIfFailed}) {
  if (retryIfFailed && ref.read(firebaseSetupProvider).hasError) {
    ref.invalidate(firebaseSetupProvider);
  }
  return ref.read(firebaseSetupProvider.future);
};

/// App Check のデバッグトークン (dev ビルドで設定画面に表示する)
@riverpod
Future<String> appCheckDebugToken(Ref ref) => AppCheckDebugToken.loadOrCreate();
