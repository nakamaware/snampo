// FLAVOR=prod の Firebase の設定 (いずれも公開値のためコミットする)
//
// 値は Terraform の output (`terraform output firebase_options`) から更新する。
// 手順は docs/coop-play-setup.md を参照。未設定 (`FirebaseOptionsProd.isConfigured` が false) の間は、
// Firebase を初期化せずに協力プレイだけを使えない状態にする。

import 'package:firebase_core/firebase_core.dart';

/// FLAVOR=prod の Firebase の設定
class FirebaseOptionsProd {
  FirebaseOptionsProd._();

  static const _unset = 'UNSET';

  /// Android の設定
  static const android = FirebaseOptions(
    apiKey: _unset,
    appId: _unset,
    messagingSenderId: _unset,
    projectId: 'snampo-prod',
    storageBucket: 'snampo-prod-coop',
  );

  /// iOS の設定
  static const ios = FirebaseOptions(
    apiKey: _unset,
    appId: _unset,
    messagingSenderId: _unset,
    projectId: 'snampo-prod',
    storageBucket: 'snampo-prod-coop',
    iosBundleId: 'com.nakamaware.snampo',
  );

  /// Terraform の output で値を更新済みか
  static bool get isConfigured =>
      android.appId != _unset && ios.appId != _unset;
}
