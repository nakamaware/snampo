import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

part 'mission_entity.freezed.dart';

/// ミッション情報エンティティ
@freezed
abstract class MissionEntity with _$MissionEntity {
  /// ミッション情報を作成する
  ///
  /// [departure] は出発地点の座標
  /// [destination] は目的地の座標と画像
  /// [waypoints] は通過地点のリスト（デフォルトは空リスト）
  /// [overviewPolyline] はルートのポリライン文字列
  /// [radius] はミッションの検索半径
  const factory MissionEntity({
    /// 出発地点
    required Coordinate departure,

    /// 目的地
    required ImageCoordinate destination,

    /// ルートのポリライン文字列
    required String overviewPolyline,

    /// ミッションの検索半径 (目的地指定モードの場合は null)
    Radius? radius,

    /// 通過地点のリスト
    @Default([]) List<ImageCoordinate> waypoints,
  }) = _MissionEntity;
}
