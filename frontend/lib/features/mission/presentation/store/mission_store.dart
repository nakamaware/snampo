import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

part 'mission_store.freezed.dart';
part 'mission_store.g.dart';

/// ミッションストアのパラメータ (Union型)
@freezed
sealed class MissionStoreParams with _$MissionStoreParams {
  /// ランダムモードのパラメータ
  ///
  /// [radius] はミッションの検索半径
  const factory MissionStoreParams.random({required Radius radius}) =
      MissionStoreParamsRandom;

  /// 目的地指定モードのパラメータ
  ///
  /// [destination] は目的地の座標
  const factory MissionStoreParams.destination({
    required Coordinate destination,
  }) = MissionStoreParamsDestination;
}

/// ミッション情報を管理するストア
@riverpod
class MissionStoreNotifier extends _$MissionStoreNotifier {
  @override
  Future<MissionEntity> build(MissionStoreParams params) async {
    final useCase = ref.read(getMissionUseCaseProvider);
    return params.when(
      random: (radius) => useCase.call(radius: radius),
      destination: (destination) => useCase.call(destination: destination),
    );
  }
}
