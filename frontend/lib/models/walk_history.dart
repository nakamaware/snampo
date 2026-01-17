import 'dart:convert';

import 'package:snampo/models/game_session.dart';
import 'package:snampo/models/location_entity.dart';
import 'package:snampo/utils/distance_calculator.dart';

/// 散歩履歴を表すエンティティ
class WalkHistory {
  /// WalkHistoryのコンストラクタ
  WalkHistory({
    required this.id,
    required this.completedAt,
    required this.distanceMeters,
    required this.overviewPolyline,
    required this.photoPaths,
    required this.destination,
    required this.midpoints,
  });

  /// GameSessionからWalkHistoryを生成する
  ///
  /// [session] は完了したゲームセッション
  /// セッションが完了していない場合は例外を投げる
  factory WalkHistory.fromGameSession(GameSession session) {
    if (session.status != GameStatus.completed) {
      throw ArgumentError('セッションが完了していません');
    }

    final distanceMeters = DistanceCalculator.calculateDistanceFromPolyline(
      session.locationEntity.overviewPolyline,
    );

    return WalkHistory(
      id: _generateId(session.startedAt),
      completedAt: DateTime.now(),
      distanceMeters: distanceMeters,
      overviewPolyline: session.locationEntity.overviewPolyline,
      photoPaths: List<String?>.from(session.photoPaths),
      destination: session.locationEntity.destination,
      midpoints: List<MidPointEntity>.from(session.locationEntity.midpoints),
    );
  }

  /// JSONからWalkHistoryを生成する
  factory WalkHistory.fromJson(Map<String, dynamic> json) {
    final completedAtString = json['completedAt'] as String;
    final completedAt = DateTime.tryParse(completedAtString);
    if (completedAt == null) {
      throw FormatException('Invalid DateTime format: $completedAtString');
    }

    final photoPaths = (json['photoPaths'] as List<dynamic>?)
            ?.map((e) => e as String?)
            .toList() ??
        [];

    final midpoints = (json['midpoints'] as List<dynamic>?)
            ?.map((e) => MidPointEntity.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WalkHistory(
      id: json['id'] as String,
      completedAt: completedAt,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      overviewPolyline: json['overviewPolyline'] as String?,
      photoPaths: photoPaths,
      destination: json['destination'] != null
          ? MidPointEntity.fromJson(
              json['destination'] as Map<String, dynamic>,
            )
          : null,
      midpoints: midpoints,
    );
  }

  /// JSON文字列からWalkHistoryを生成する
  static WalkHistory? fromJsonString(String? jsonString) {
    if (jsonString == null) return null;
    try {
      return WalkHistory.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// ユニークIDを生成する
  static String _generateId(DateTime startedAt) {
    final startMs = startedAt.millisecondsSinceEpoch;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return '${startMs}_$nowMs';
  }

  /// 履歴のID
  final String id;

  /// 完了日時
  final DateTime completedAt;

  /// 総距離 (メートル単位)
  final double distanceMeters;

  /// ルートのポリライン文字列
  final String? overviewPolyline;

  /// 各スポットの写真パスのリスト
  /// インデックス0がmidpoints[0]、インデックス1がdestinationに対応
  final List<String?> photoPaths;

  /// 目的地
  final MidPointEntity? destination;

  /// 中間地点のリスト
  final List<MidPointEntity> midpoints;

  /// WalkHistoryをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'distanceMeters': distanceMeters,
      'overviewPolyline': overviewPolyline,
      'photoPaths': photoPaths,
      'destination': destination?.toJson(),
      'midpoints': midpoints.map((e) => e.toJson()).toList(),
    };
  }

  /// WalkHistoryをJSON文字列に変換する
  String toJsonString() => jsonEncode(toJson());

  /// 距離をキロメートル単位で取得する
  double get distanceKilometers => distanceMeters / 1000.0;

  /// 指定されたインデックスの写真パスを取得する
  String? getPhotoPath(int index) {
    if (index < 0 || index >= photoPaths.length) return null;
    return photoPaths[index];
  }
}
