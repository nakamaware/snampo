import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';

void main() {
  final joined = DateTime.utc(2026, 9, 29, 10);

  group('namedAt', () {
    test('名前を変えていなければ入室時刻', () {
      final member = RoomMember(uid: 'a', nickname: 'たろう', joinedAt: joined);
      expect(member.namedAt, joined);
    });

    test('入室後に名前を変えていれば、変えた時刻', () {
      final renamed = joined.add(const Duration(minutes: 3));
      final member = RoomMember(
        uid: 'a',
        nickname: 'たろう',
        joinedAt: joined,
        renamedAt: renamed,
      );
      expect(member.namedAt, renamed);
    });

    test('入り直す前の名前変更は使わない (入り直した時刻になる)', () {
      final member = RoomMember(
        uid: 'a',
        nickname: 'たろう',
        joinedAt: joined,
        renamedAt: joined.subtract(const Duration(minutes: 5)),
      );
      expect(member.namedAt, joined);
    });
  });
}
