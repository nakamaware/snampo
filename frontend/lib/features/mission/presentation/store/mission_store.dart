import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

part 'mission_store.freezed.dart';
part 'mission_store.g.dart';

/// リトライを無効化する (1 回の失敗で即座にエラー状態にする)
Duration? _noRetry(int count, Object error) => null;

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
@Riverpod(retry: _noRetry)
class MissionStoreNotifier extends _$MissionStoreNotifier {
  @override
  Future<MissionEntity> build(MissionStoreParams params) async {
    return params.when(
      random: (radius) {
        final useCase = ref.read(createRandomMissionUseCaseProvider);
        return useCase.call(radius);
      },
      destination: (destination) {
        final useCase = ref.read(createDestinationMissionUseCaseProvider);
        return useCase.call(destination);
      },
    );
  }
}
