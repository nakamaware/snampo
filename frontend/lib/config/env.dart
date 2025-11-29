/// 環境設定を管理するクラス
///
/// ビルド時に `--dart-define` で値を渡すことで環境ごとの設定を切り替えます
class Env {
  Env._();

  /// 環境フレーバー（dev/prod）
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// APIサーバーのベースURL
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://52.197.206.202',
  );
}
