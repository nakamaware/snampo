import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/watch_room_use_case.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  final rooms = FakeRoomRepository();
  rooms.members[fx.code] = [
    fx.member('host'),
    fx.member('me', joinedMinutes: 1),
  ];
  final useCase = WatchRoomUseCase(rooms);

  test('メンバーだけを監視するときは、メンバーの一覧を流す', () async {
    final members = await useCase.members(fx.code).first;
    expect([for (final m in members) m.uid], ['host', 'me']);
  });

  test('サーバの最新の値と確かめられたかも伝える', () async {
    final snapshot = await useCase.memberSnapshots(fx.code).first;
    expect([for (final m in snapshot.members) m.uid], ['host', 'me']);
    expect(snapshot.isUpToDate, isTrue);
  });
}
