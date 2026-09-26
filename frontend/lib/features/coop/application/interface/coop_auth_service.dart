/// 協力プレイのサインインに失敗した理由
enum CoopAuthFailure {
  /// オフライン
  offline,

  /// App Check に拒否された
  appCheck,

  /// その他 (Firebase の初期化に失敗した場合を含む)
  other,
}

/// 協力プレイのサインインの例外
class CoopAuthException implements Exception {
  /// [CoopAuthException] を作成する
  const CoopAuthException(this.failure, [this.code]);

  /// 失敗した理由
  final CoopAuthFailure failure;

  /// 原因のコード (表示用)
  final String? code;

  @override
  String toString() => 'CoopAuthException($failure, $code)';
}

/// 協力プレイの認証 (Firebase Auth 匿名)
abstract class ICoopAuthService {
  /// サインイン済みならその uid を返す。未サインインなら null (サインインは試さない)
  Future<String?> signedInUid();

  /// サインイン済みならその uid を返し、未サインインならサインインする
  ///
  /// 失敗したら [CoopAuthException] を投げる。
  Future<String> ensureSignedIn();
}
