import 'package:snampo/features/coop/application/interface/coop_auth_service.dart';

/// サインイン済みなら Auth の uid を返す (未サインインなら null)
///
/// サインインは試さない (サインインを再試行するタイミングは決まっているため)。
class GetCoopSignedInUidUseCase {
  /// [GetCoopSignedInUidUseCase] を作成する
  GetCoopSignedInUidUseCase(this._auth);

  final ICoopAuthService _auth;

  /// uid を返す
  Future<String?> call() => _auth.signedInUid();
}
