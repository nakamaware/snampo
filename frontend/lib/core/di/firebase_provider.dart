import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/firebase/firebase_initializer.dart';

part 'firebase_provider.g.dart';

/// Firebase の初期化 (アプリ全体で 1 回だけ)
///
/// 失敗したらエラー状態になる。ソロプレイはこれに依存しない。
@Riverpod(keepAlive: true)
Future<FirebaseSetup> firebaseSetup(Ref ref) => initializeFirebase();
