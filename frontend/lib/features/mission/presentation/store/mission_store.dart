import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

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

  /// 保存済みミッションから再開する（API は呼ばず永続から復元）
  const factory MissionStoreParams.resume() = MissionStoreParamsResume;
}

/// ミッション情報を取得するストア（ランダム / 目的地 / 再開）
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
      resume: () async {
        final saved = await ref.read(persistedMissionProvider.future);
        if (saved == null) {
          throw StateError('保存されたミッションがありません');
        }
        return saved;
      },
    );
  }

  /// 再開用に永続化しているミッションをクリアする（完了画面など）
  ///
  /// 実体は [persistedMissionProvider] への委譲。
  void clearMission() {
    ref.read(persistedMissionProvider.notifier).clearMission();
  }
}
