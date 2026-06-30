import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

part 'mission_settings.freezed.dart';

/// 履歴に保存するミッション開始時の設定
@freezed
sealed class MissionSettings with _$MissionSettings {
  /// ランダムモード (探索半径)
  const factory MissionSettings.random({required Radius radius}) =
      MissionSettingsRandom;

  /// 目的地指定モード (ユーザーが指定した目的地座標)
  const factory MissionSettings.destination({required Coordinate destination}) =
      MissionSettingsDestination;
}
