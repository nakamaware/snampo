import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/resolve_unshared_captures_use_case.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  const capture = CheckpointProgress(userPhotoPath: '/photos/a.jpg');
  late FakeRoomRepository rooms;
  late ResolveUnsharedCapturesUseCase useCase;

  setUp(() {
    rooms = FakeRoomRepository();
    useCase = ResolveUnsharedCapturesUseCase(rooms: rooms);
  });

  test('サーバにクリアがないスポットの撮影は捨てる', () async {
    final discard = await useCase(fx.code, {
      fx.spot('a'): capture,
      fx.spot('b'): capture,
    });

    expect(discard, {fx.spot('a'), fx.spot('b')});
  });

  test('サーバにクリアがあるスポットの撮影は捨てない (先着に負けた場合を含む)', () async {
    rooms.clears[fx.code] = {fx.spot('a'): fx.clear('a', 'other')};

    final discard = await useCase(fx.code, {
      fx.spot('a'): capture,
      fx.spot('b'): capture,
    });

    expect(discard, {fx.spot('b')});
  });

  test('サーバからクリアを読めなければ (オフラインなど)、判断できないので捨てない', () async {
    rooms.offline = true;

    final discard = await useCase(fx.code, {fx.spot('a'): capture});

    expect(discard, isEmpty);
  });
}
