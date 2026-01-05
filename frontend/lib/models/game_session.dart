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
    List<String?>? photoPaths,
  }) : photoPaths = photoPaths ?? [];

  /// JSONからGameSessionを生成する
  factory GameSession.fromJson(Map<String, dynamic> json) {
    final photoPaths = (json['photoPaths'] as List<dynamic>?)
            ?.map((e) => e as String?)
            .toList() ??
        [];

    return GameSession(
      locationEntity: LocationEntity.fromJson(
        json['locationEntity'] as Map<String, dynamic>,
      ),
      radius: (json['radius'] as num).toDouble(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      status: GameStatus.values.byName(json['status'] as String),
      photoPaths: photoPaths,
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

  /// 各スポットの写真パスのリスト
  /// インデックス0がmidpoints[0]、インデックス1がdestinationに対応
  final List<String?> photoPaths;

  /// 指定されたインデックスの写真パスを取得する
  String? getPhotoPath(int index) {
    if (index < 0 || index >= photoPaths.length) return null;
    return photoPaths[index];
  }

  /// GameSessionをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'locationEntity': locationEntity.toJson(),
      'radius': radius,
      'startedAt': startedAt.toIso8601String(),
      'status': status.name,
      'photoPaths': photoPaths,
    };
  }

  /// 写真パスを更新した新しいGameSessionを作成する
  GameSession copyWith({
    List<String?>? photoPaths,
  }) {
    return GameSession(
      locationEntity: locationEntity,
      radius: radius,
      startedAt: startedAt,
      status: status,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  /// 指定されたインデックスの写真パスを更新した新しいGameSessionを作成する
  GameSession copyWithPhotoPath(int index, String? photoPath) {
    final updatedPhotoPaths = List<String?>.from(photoPaths);
    // インデックスが範囲外の場合はリストを拡張
    while (updatedPhotoPaths.length <= index) {
      updatedPhotoPaths.add(null);
    }
    updatedPhotoPaths[index] = photoPath;
    return copyWith(photoPaths: updatedPhotoPaths);
  }

  /// GameSessionをJSON文字列に変換する
  String toJsonString() => jsonEncode(toJson());
}
