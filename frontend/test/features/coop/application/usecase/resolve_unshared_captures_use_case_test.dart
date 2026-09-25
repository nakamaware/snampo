import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/resolve_unshared_captures_use_case.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';
import '../coop_history_fixture.dart';

void main() {
  const capture = CheckpointProgress(userPhotoPath: '/photos/a.jpg');
  late FakeRoomRepository rooms;
  late FakeHistoryRepository histories;
  late ResolveUnsharedCapturesUseCase useCase;

  setUp(() async {
    rooms = FakeRoomRepository();
    histories = FakeHistoryRepository();
    await seedCoopHistory(histories);
    useCase = ResolveUnsharedCapturesUseCase(
      rooms: rooms,
      histories: histories,
    );
  });

  String? photoInHistory(String spotId) =>
      histories.histories[fx.code]!.spots
          .firstWhere((s) => s.spotId == fx.spot(spotId))
          .userPhotoPath;

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

  test('捨てない撮影は、自分の写真と採点を履歴に残す (共有の途中で終了して、残せていない)', () async {
    rooms.clears[fx.code] = {fx.spot('a'): fx.clear('a', 'other')};

    await useCase(fx.code, {fx.spot('a'): capture, fx.spot('b'): capture});

    expect(photoInHistory('a'), '/photos/a.jpg');
    expect(photoInHistory('b'), isNull);
  });

  test('サーバからクリアを読めなければ (オフラインなど)、判断できないので捨てない', () async {
    rooms.offline = true;

    final discard = await useCase(fx.code, {fx.spot('a'): capture});

    expect(discard, isEmpty);
    expect(photoInHistory('a'), isNull);
  });
}
