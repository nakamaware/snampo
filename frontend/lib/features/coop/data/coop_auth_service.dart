import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snampo/core/firebase/firebase_initializer.dart';
import 'package:snampo/features/coop/application/interface/coop_auth_service.dart';

/// Firebase Auth (匿名) と App Check による協力プレイの認証
///
/// 一度サインインすれば uid は端末に残り、次回以降はネットワークなしで復元される。
class CoopAuthService implements ICoopAuthService {
  /// [CoopAuthService] を作成する
  CoopAuthService(this._firebaseSetup);

  /// Firebase の初期化を待つ (`retryIfFailed` なら、前の失敗から初期化し直す)
  final Future<FirebaseSetup> Function({required bool retryIfFailed})
  _firebaseSetup;

  static Future<bool> _isOffline() async {
    final results = await Connectivity().checkConnectivity();
    return results.every((r) => r == ConnectivityResult.none);
  }

  @override
  Future<String?> signedInUid() async {
    try {
      // 通信しない読み取りなので、初期化に失敗していても初期化し直さない
      await _firebaseSetup(retryIfFailed: false);
    } on Object {
      return null;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<String> ensureSignedIn() async {
    try {
      // サインインを試すときは、前の初期化に失敗していれば初期化し直す
      await _firebaseSetup(retryIfFailed: true);
    } on Object catch (e) {
      throw CoopAuthException(
        CoopAuthFailure.other,
        e is FirebaseUnavailableException ? 'firebase-unavailable' : '$e',
      );
    }

    final auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if (user == null) {
      if (await _isOffline()) {
        throw const CoopAuthException(CoopAuthFailure.offline);
      }
      try {
        user = (await auth.signInAnonymously()).user;
      } on FirebaseAuthException catch (e) {
        throw CoopAuthException(
          e.code == 'network-request-failed'
              ? CoopAuthFailure.offline
              : CoopAuthFailure.other,
          e.code,
        );
      }
    }
    if (user == null) {
      throw const CoopAuthException(CoopAuthFailure.other, 'no-user');
    }

    // Firestore と Storage は App Check を強制しているので、先にトークンを取れるか確かめる
    try {
      await FirebaseAppCheck.instance.getToken();
    } on FirebaseException catch (e) {
      if (await _isOffline()) {
        throw const CoopAuthException(CoopAuthFailure.offline);
      }
      throw CoopAuthException(CoopAuthFailure.appCheck, e.code);
    }
    return user.uid;
  }
}
