import 'dart:io';

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

  /// ゲームセッションを削除する (写真ファイルも削除)
  Future<void> clearSession() async {
    // 保存された写真ファイルを削除
    final session = await getSavedSession();
    if (session != null) {
      await _deletePhotoFile(session.spot1PhotoPath);
      await _deletePhotoFile(session.spot2PhotoPath);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 中断中のゲームがあるかチェックする
  Future<bool> hasSavedSession() async {
    final session = await getSavedSession();
    return session != null && session.status == GameStatus.inProgress;
  }

  /// 写真ファイルを削除する
  Future<void> _deletePhotoFile(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (_) {
      // ファイル削除に失敗しても無視
    }
  }
}
