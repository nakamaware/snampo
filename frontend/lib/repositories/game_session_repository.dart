import 'package:shared_preferences/shared_preferences.dart';
import 'package:snampo/models/game_session.dart';

/// ゲームセッションの永続化を担当するリポジトリ
class GameSessionRepository {
  static const String _key = 'current_game_session';

  /// 保存中のゲームセッションを取得する
  Future<GameSession?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    return GameSession.fromJsonString(jsonString);
  }

  /// ゲームセッションを保存する
  Future<void> saveSession(GameSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, session.toJsonString());
  }

  /// ゲームセッションを削除する
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 中断中のゲームがあるかチェックする
  Future<bool> hasSavedSession() async {
    final session = await getSavedSession();
    return session != null && session.status == GameStatus.inProgress;
  }
}
