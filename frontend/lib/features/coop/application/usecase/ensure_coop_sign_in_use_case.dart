import 'package:snampo/features/coop/application/interface/coop_auth_service.dart';

/// 協力プレイのサインインを済ませ、Auth の uid を返す
///
/// 未サインインならサインインする。失敗したら [CoopAuthException] を投げる。
/// 「みんなで」を押したとき、フォアグラウンドに復帰したとき、起動時に呼ぶ。
class EnsureCoopSignInUseCase {
  /// [EnsureCoopSignInUseCase] を作成する
  EnsureCoopSignInUseCase(this._auth);

  final ICoopAuthService _auth;

  /// サインインを済ませる
  Future<String> call() => _auth.ensureSignedIn();
}
