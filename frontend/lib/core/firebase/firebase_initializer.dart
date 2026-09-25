import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:snampo/config.dart';
import 'package:snampo/core/firebase/app_check_debug_token.dart';
import 'package:snampo/core/firebase/firebase_options.dart';

/// Firebase を使えない (初期化に失敗した、または設定が未反映)
class FirebaseUnavailableException implements Exception {
  /// [FirebaseUnavailableException] を作成する
  const FirebaseUnavailableException(this.message);

  /// 理由
  final String message;

  @override
  String toString() => 'FirebaseUnavailableException: $message';
}

/// Firebase の初期化結果
class FirebaseSetup {
  /// [FirebaseSetup] を作成する
  const FirebaseSetup({required this.appCheckDebugToken});

  /// App Check のデバッグトークン (dev ビルドのみ。prod では null)
  final String? appCheckDebugToken;
}

/// Firebase の初期化を待つ関数
///
/// [retryIfFailed] が true で、前の初期化に失敗していれば、初期化し直す
/// (「みんなで」を押したときや「再試行」など)。
typedef FirebaseSetupReader =
    Future<FirebaseSetup> Function({required bool retryIfFailed});

/// Firebase と App Check を初期化する
///
/// | FLAVOR | Android | iOS |
/// |---|---|---|
/// | prod | Play Integrity | App Attest (DeviceCheck へのフォールバックあり) |
/// | dev | Debug provider | Debug provider |
///
/// 失敗しても例外はソロプレイに影響させない (協力プレイの中でだけ扱う)。
Future<FirebaseSetup> initializeFirebase() async {
  final isDev = Env.flavor != 'prod';
  final options = firebaseOptionsFor(
    isProd: !isDev,
    platform: defaultTargetPlatform,
  );
  if (options == null) {
    throw const FirebaseUnavailableException(
      'Firebase の設定 (dart-define の FIREBASE_*) が未設定です',
    );
  }
  await Firebase.initializeApp(options: options);

  if (isDev) {
    final token = await AppCheckDebugToken.loadOrCreate();
    // クラウド上の AI エージェントがログから拾い、人に渡せるようにするため、ログにも出力する
    debugPrint('[AppCheck] debug token: $token');
    await FirebaseAppCheck.instance.activate(
      providerAndroid: AndroidDebugProvider(debugToken: token),
      providerApple: AppleDebugProvider(debugToken: token),
    );
    return FirebaseSetup(appCheckDebugToken: token);
  }
  // Android は既定の Play Integrity を使う
  await FirebaseAppCheck.instance.activate(
    providerApple: const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );
  return const FirebaseSetup(appCheckDebugToken: null);
}
