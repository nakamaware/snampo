import 'dart:convert';

import 'package:snampo/models/location_entity.dart';

/// ゲームの状態を表す列挙型
enum GameStatus {
  /// ゲーム進行中
  inProgress,

  /// ゲーム完了
  completed,
}

/// ゲームセッションを表すエンティティ
class GameSession {
  /// GameSessionのコンストラクタ
  GameSession({
    required this.locationEntity,
    required this.radius,
    required this.startedAt,
    required this.status,
  });

  /// JSONからGameSessionを生成する
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      locationEntity: LocationEntity.fromJson(
        json['locationEntity'] as Map<String, dynamic>,
      ),
      radius: (json['radius'] as num).toDouble(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      status: GameStatus.values.byName(json['status'] as String),
    );
  }

  /// JSON文字列からGameSessionを生成する
  static GameSession? fromJsonString(String? jsonString) {
    if (jsonString == null) return null;
    try {
      return GameSession.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// ミッション情報
  final LocationEntity locationEntity;

  /// 検索半径 (キロメートル単位)
  final double radius;

  /// ゲーム開始時刻
  final DateTime startedAt;

  /// ゲームの状態
  final GameStatus status;

  /// GameSessionをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'locationEntity': locationEntity.toJson(),
      'radius': radius,
      'startedAt': startedAt.toIso8601String(),
      'status': status.name,
    };
  }

  /// GameSessionをJSON文字列に変換する
  String toJsonString() => jsonEncode(toJson());
}
