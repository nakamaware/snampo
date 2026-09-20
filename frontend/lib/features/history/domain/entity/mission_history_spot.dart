import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

part 'mission_history_spot.freezed.dart';

/// ミッション履歴内の1スポット
@freezed
abstract class MissionHistorySpot with _$MissionHistorySpot {
  /// [MissionHistorySpot] を作成する
  const factory MissionHistorySpot({
    required Coordinate coordinate,
    required int sortOrder,
    required bool isDestination,
    required String streetViewImagePath,
    String? userPhotoPath,
    DateTime? achievedAt,
    String? name,
    String? genre,
    String? googleMapsUrl,
    double? referenceHeading,
    PhotoJudgeRank? judgeRank,
    double? distanceErrorMeters,
    double? headingErrorDegrees,
    Coordinate? guessPosition,
    double? capturedHeading,
  }) = _MissionHistorySpot;
}
