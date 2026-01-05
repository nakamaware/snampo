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
    this.spot1PhotoPath,
    this.spot2PhotoPath,
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
      spot1PhotoPath: json['spot1PhotoPath'] as String?,
      spot2PhotoPath: json['spot2PhotoPath'] as String?,
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

  /// Spot1の写真パス
  final String? spot1PhotoPath;

  /// Spot2の写真パス
  final String? spot2PhotoPath;

  /// GameSessionをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'locationEntity': locationEntity.toJson(),
      'radius': radius,
      'startedAt': startedAt.toIso8601String(),
      'status': status.name,
      'spot1PhotoPath': spot1PhotoPath,
      'spot2PhotoPath': spot2PhotoPath,
    };
  }

  /// 写真パスを更新した新しいGameSessionを作成する
  GameSession copyWith({
    String? spot1PhotoPath,
    String? spot2PhotoPath,
  }) {
    return GameSession(
      locationEntity: locationEntity,
      radius: radius,
      startedAt: startedAt,
      status: status,
      spot1PhotoPath: spot1PhotoPath ?? this.spot1PhotoPath,
      spot2PhotoPath: spot2PhotoPath ?? this.spot2PhotoPath,
    );
  }

  /// GameSessionをJSON文字列に変換する
  String toJsonString() => jsonEncode(toJson());
}
