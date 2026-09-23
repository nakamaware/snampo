import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/firebase/app_check_debug_token.dart';
import 'package:snampo/core/firebase/firebase_initializer.dart';

part 'firebase_provider.g.dart';

/// Firebase の初期化 (アプリ全体で 1 回だけ)
///
/// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。
@Riverpod(keepAlive: true)
Future<FirebaseSetup> firebaseSetup(Ref ref) => initializeFirebase();

/// App Check のデバッグトークン (dev ビルドで設定画面に表示する)
@riverpod
Future<String> appCheckDebugToken(Ref ref) => AppCheckDebugToken.loadOrCreate();
