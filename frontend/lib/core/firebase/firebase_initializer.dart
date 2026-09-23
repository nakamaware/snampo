import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:snampo/config.dart';
import 'package:snampo/core/firebase/app_check_debug_token.dart';
import 'package:snampo/core/firebase/firebase_options_dev.dart';
import 'package:snampo/core/firebase/firebase_options_prod.dart';

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
  final configured =
      isDev
          ? FirebaseOptionsDev.isConfigured
          : FirebaseOptionsProd.isConfigured;
  if (!configured) {
    throw const FirebaseUnavailableException(
      'Firebase の設定 (firebase_options_*.dart) が未反映です',
    );
  }
  final isIos = defaultTargetPlatform == TargetPlatform.iOS;
  final options = switch ((isDev, isIos)) {
    (true, true) => FirebaseOptionsDev.ios,
    (true, false) => FirebaseOptionsDev.android,
    (false, true) => FirebaseOptionsProd.ios,
    (false, false) => FirebaseOptionsProd.android,
  };
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
