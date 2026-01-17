import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

part 'mission_store.g.dart';

/// ミッション情報を管理するストア
@riverpod
class MissionStoreNotifier extends _$MissionStoreNotifier {
  @override
  Future<MissionEntity> build(Radius radius) async {
    final useCase = ref.read(getMissionUseCaseProvider);
    return useCase.call(radius);
  }
}
