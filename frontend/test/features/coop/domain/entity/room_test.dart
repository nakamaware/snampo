import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

import 'coop_fixtures.dart';

void main() {
  group('Room', () {
    test('期限はルーム作成から 12 時間 (遊べる期限) と 7 日 (保持期限)', () {
      expect(Room.playableDuration, const Duration(hours: 12));
      expect(Room.retentionDuration, const Duration(days: 7));
    });

    test('遊べる期限の前だけ遊べる', () {
      final r = room();

      expect(r.isPlayable(createdAt.add(const Duration(hours: 11))), isTrue);
      expect(r.isPlayable(createdAt.add(const Duration(hours: 12))), isFalse);
    });
  });

  group('Room.hasEnded', () {
    test('遊んでいる途中なら終わっていない', () {
      final target = room();
      expect(target.hasEnded(createdAt), isFalse);
    });

    test('finished なら終わっている', () {
      final target = room(status: RoomStatus.finished);
      expect(target.hasEnded(createdAt), isTrue);
    });

    test('遊べる期限を過ぎたら、status にかかわらず終わっている', () {
      final target = room();
      expect(target.hasEnded(target.expiresAt), isTrue);
    });
  });

  group('checkJoinable', () {
    final now = createdAt.add(const Duration(hours: 1));

    test('存在しないルームには入れない', () {
      expect(checkJoinable(null, now), JoinRoomError.notFound);
    });

    test('waiting / generating / playing のルームには入れる', () {
      for (final status in [
        RoomStatus.waiting,
        RoomStatus.generating,
        RoomStatus.playing,
      ]) {
        expect(checkJoinable(room(status: status), now), isNull);
      }
    });

    test('finished のルームには入れない', () {
      expect(
        checkJoinable(room(status: RoomStatus.finished), now),
        JoinRoomError.finished,
      );
    });

    test('遊べる期限を過ぎたルームには入れない', () {
      expect(
        checkJoinable(room(), createdAt.add(const Duration(hours: 13))),
        JoinRoomError.expired,
      );
    });
  });

  group('isWithinCapacity', () {
    test('抜けていないメンバーのうち、入室順で 8 人目までなら入れる', () {
      final members = [
        for (var i = 0; i < 8; i++) member('u$i', joinedMinutes: i),
        member('late', joinedMinutes: 100),
      ];

      expect(isWithinCapacity(members, 'u7'), isTrue);
      expect(isWithinCapacity(members, 'late'), isFalse);
    });

    test('抜けた人は人数に数えない', () {
      final members = [
        for (var i = 0; i < 8; i++)
          member('u$i', joinedMinutes: i, left: i == 0),
        member('late', joinedMinutes: 100),
      ];

      expect(isWithinCapacity(members, 'late'), isTrue);
    });
  });

  group('isAllCleared', () {
    test('全スポットがクリアされたら true', () {
      final r = room(spotIds: ['a', 'b']);

      expect(isAllCleared(r, [clear('a', 'x'), clear('b', 'y')]), isTrue);
      expect(isAllCleared(r, [clear('a', 'x')]), isFalse);
    });

    test('スポットがなければ false', () {
      expect(isAllCleared(room(spotIds: []), []), isFalse);
    });
  });

  group('shouldFinalizeHistory', () {
    final expiresAt = createdAt.add(Room.playableDuration);

    test('ルームが finished で、サムネが全部そろったら確定する', () {
      expect(
        shouldFinalizeHistory(
          room: room(status: RoomStatus.finished),
          expiresAt: expiresAt,
          now: createdAt,
          hasAllThumbs: true,
        ),
        isTrue,
      );
    });

    test('ルームが finished でも、サムネを取得できるまでは確定しない', () {
      expect(
        shouldFinalizeHistory(
          room: room(status: RoomStatus.finished),
          expiresAt: expiresAt,
          now: createdAt,
          hasAllThumbs: false,
        ),
        isFalse,
      );
    });

    test('遊べる期限を過ぎたら、サムネがそろわなくても確定する', () {
      expect(
        shouldFinalizeHistory(
          room: room(status: RoomStatus.finished),
          expiresAt: expiresAt,
          now: expiresAt,
          hasAllThumbs: false,
        ),
        isTrue,
      );
    });

    test('ルームが消えていたら確定する', () {
      expect(
        shouldFinalizeHistory(
          room: null,
          expiresAt: expiresAt,
          now: createdAt,
          hasAllThumbs: false,
        ),
        isTrue,
      );
    });

    test('進行中なら確定しない', () {
      expect(
        shouldFinalizeHistory(
          room: room(),
          expiresAt: expiresAt,
          now: createdAt,
          hasAllThumbs: true,
        ),
        isFalse,
      );
    });
  });
}
