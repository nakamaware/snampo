// Firebase の設定
//
// API キーやアプリ ID はリポジトリに置かず、ビルド時に dart-define で渡す (secret として扱う)。
// 値の取り出し方と登録先は docs/coop-play-setup.md を参照。そのプラットフォームの値が未設定の間は、
// Firebase を初期化せずに協力プレイだけを使えない状態にする。

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// dart-define で渡す Firebase の設定の値 (未設定なら空文字)
class FirebaseDefines {
  /// [FirebaseDefines] を作成する
  const FirebaseDefines({
    required this.androidApiKey,
    required this.androidAppId,
    required this.iosApiKey,
    required this.iosAppId,
    required this.messagingSenderId,
  });

  /// ビルド時の dart-define の値
  static const fromEnvironment = FirebaseDefines(
    androidApiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    androidAppId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    iosApiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    iosAppId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
  );

  /// Android の API キー
  final String androidApiKey;

  /// Android のアプリ ID
  final String androidAppId;

  /// iOS の API キー
  final String iosApiKey;

  /// iOS のアプリ ID
  final String iosAppId;

  /// Sender ID (プロジェクト番号)
  final String messagingSenderId;
}

/// FLAVOR とプラットフォームに合う Firebase の設定を返す
///
/// そのプラットフォームの値が 1 つでも未設定なら null を返す。
FirebaseOptions? firebaseOptionsFor({
  required bool isProd,
  required TargetPlatform platform,
  FirebaseDefines defines = FirebaseDefines.fromEnvironment,
}) {
  final isIos = platform == TargetPlatform.iOS;
  final apiKey = isIos ? defines.iosApiKey : defines.androidApiKey;
  final appId = isIos ? defines.iosAppId : defines.androidAppId;
  if (apiKey.isEmpty || appId.isEmpty || defines.messagingSenderId.isEmpty) {
    return null;
  }
  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: defines.messagingSenderId,
    projectId: isProd ? 'snampo-prod' : 'snampo-480404',
    storageBucket: isProd ? 'snampo-prod-coop' : 'snampo-dev-coop',
    iosBundleId: isIos ? 'com.nakamaware.snampo' : null,
  );
}
