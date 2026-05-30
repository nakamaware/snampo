import 'dart:io';

/// 環境設定を管理するクラス
///
/// ビルド時に `--dart-define` で値を渡すことで環境ごとの設定を切り替えます
class Env {
  Env._();

  /// 環境フレーバー (dev/prod)
  static String get flavor {
    const value = String.fromEnvironment('FLAVOR');
    if (value.isEmpty) {
      throw StateError(
        'FLAVOR環境変数が設定されていません。'
        'ビルド時に `--dart-define=FLAVOR=dev` のように指定してください。',
      );
    }
    return value;
  }

  /// APIサーバーのベースURL
  static String get apiBaseUrl {
    const value = String.fromEnvironment('API_BASE_URL');
    if (value.isEmpty) {
      // API_BASE_URL が空 かつ 環境がdev かつ Android のとき
      if (flavor == 'dev' && Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
      // API_BASE_URL が空 かつ 環境がdev かつ iOS のとき
      else if (flavor == 'dev' && Platform.isIOS) {
        return 'http://localhost:8000';
      }
      // それ以外のときは API_BASE_URLが空だとエラー
      else {
        throw StateError(
          'API_BASE_URL環境変数が設定されていません。'
          'ビルド時に `--dart-define=API_BASE_URL=http://example.com` のように指定してください。',
        );
      }
    }
    return value;
  }
}
