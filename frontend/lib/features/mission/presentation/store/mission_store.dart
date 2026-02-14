import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

part 'mission_store.g.dart';

/// リトライを無効化する ( 1 回の失敗で即座にエラー状態にする )
Duration? _noRetry(int count, Object error) => null;

/// ミッション情報を管理するストア
@Riverpod(retry: _noRetry)
class MissionStoreNotifier extends _$MissionStoreNotifier {
  @override
  Future<MissionEntity> build(Radius radius) async {
    final useCase = ref.read(getMissionUseCaseProvider);
    return useCase.call(radius);
  }
}
