import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/application/interface/mission_repository.dart';
import 'package:snampo/features/mission/application/usecase/create_random_mission_use_case.dart';

class _NoLocation implements ILocationService {
  @override
  Future<Coordinate> getCurrentPosition() async =>
      throw const LocationUnavailableException('disabled');
}

class _UnusedRepository implements IMissionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('現在地がないので呼ばれない');
}

void main() {
  test('現在地を取得できなければ、LocationUnavailableException をそのまま投げる', () {
    final useCase = CreateRandomMissionUseCase(
      _NoLocation(),
      _UnusedRepository(),
    );

    expect(
      () => useCase(Radius(meters: 500)),
      throwsA(isA<LocationUnavailableException>()),
    );
  });
}
