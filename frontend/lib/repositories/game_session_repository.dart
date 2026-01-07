import 'dart:io';

import 'package:path_provider/path_provider.dart';
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
      for (final photoPath in session.photoPaths) {
        await _deletePhotoFile(photoPath);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 中断中のゲームがあるかチェックする
  Future<bool> hasSavedSession() async {
    final session = await getSavedSession();
    return session != null && session.status == GameStatus.inProgress;
  }

  /// 写真を保存してセッションを更新する
  ///
  /// [sourcePath] は保存元の写真ファイルパス
  /// [spotIndex] はスポットのインデックス (0がmidpoints[0], 1がdestinationに対応)
  /// セッションが存在しない場合は例外を投げる
  /// 更新されたセッションを返す
  Future<GameSession> savePhotoAndUpdateSession(
    String sourcePath,
    int spotIndex,
  ) async {
    final session = await getSavedSession();
    if (session == null) {
      throw StateError('ゲームセッションが存在しません');
    }

    final savedPath = await _savePhotoToDocuments(sourcePath, spotIndex);
    final updatedSession = session.copyWithPhotoPath(spotIndex, savedPath);
    await saveSession(updatedSession);

    return updatedSession;
  }

  /// 写真をドキュメントディレクトリに保存する
  Future<String> _savePhotoToDocuments(String sourcePath, int spotIndex) async {
    final directory = await getApplicationDocumentsDirectory();
    final extension = sourcePath.split('.').last;
    final fileName =
        'snampo_spot${spotIndex}_${DateTime.now().millisecondsSinceEpoch}'
        '.$extension';
    final destPath = '${directory.path}/$fileName';

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    return destPath;
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
