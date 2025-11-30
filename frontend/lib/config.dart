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
      throw StateError(
        'API_BASE_URL環境変数が設定されていません。'
        'ビルド時に `--dart-define=API_BASE_URL=http://example.com` のように指定してください。',
      );
    }
    return value;
  }
}
