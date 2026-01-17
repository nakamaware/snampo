import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:snampo/models/walk_history.dart';

/// 散歩履歴の永続化を担当するリポジトリ
class WalkHistoryRepository {
  static const String _key = 'walk_history_list';

  /// すべての履歴を取得する
  ///
  /// 完了日時の降順 (新しい順) でソートして返す
  Future<List<WalkHistory>> getAllHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final histories = jsonList
          .map((e) => WalkHistory.fromJson(e as Map<String, dynamic>))
          .toList();

      // 完了日時の降順でソート
      return histories..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } catch (_) {
      return [];
    }
  }

  /// 履歴を保存する
  ///
  /// [history] は保存する履歴
  Future<void> saveHistory(WalkHistory history) async {
    final histories = await getAllHistories();
    // 完了日時の降順でソート
    histories
      ..add(history)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final prefs = await SharedPreferences.getInstance();
    final jsonList = histories.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// 指定されたIDの履歴を取得する
  ///
  /// [id] は履歴のID
  /// 見つからない場合は null を返す
  Future<WalkHistory?> getHistoryById(String id) async {
    final histories = await getAllHistories();
    try {
      return histories.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 指定されたIDの履歴を削除する
  ///
  /// [id] は削除する履歴のID
  Future<void> deleteHistory(String id) async {
    final histories = await getAllHistories();
    histories.removeWhere((h) => h.id == id);

    final prefs = await SharedPreferences.getInstance();
    if (histories.isEmpty) {
      await prefs.remove(_key);
    } else {
      final jsonList = histories.map((e) => e.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    }
  }

  /// すべての履歴を削除する
  Future<void> clearAllHistories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
