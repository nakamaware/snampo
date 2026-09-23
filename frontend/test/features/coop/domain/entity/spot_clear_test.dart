import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';

import 'coop_fixtures.dart';

void main() {
  group('planClearSync', () {
    test('ローカルにない発見者とサムネを取得の対象にする', () {
      final plan = planClearSync(
        clears: [
          clear('a', 'x', thumbPath: 'rooms/R/thumbs/a/x.jpg'),
          clear('b', 'y'),
          clear('c', 'z', thumbPath: 'rooms/R/thumbs/c/z.jpg'),
        ],
        local: {
          'a': const LocalClearState(discovererUid: 'x', hasThumb: true),
          'c': const LocalClearState(discovererUid: 'z', hasThumb: false),
        },
      );

      expect(plan.discoverersToApply.map((c) => c.spotId), ['b']);
      expect(plan.thumbsToFetch.map((c) => c.spotId), ['c']);
    });

    test('新しく知ったクリアのサムネも取得する', () {
      final plan = planClearSync(
        clears: [clear('a', 'x', thumbPath: 'rooms/R/thumbs/a/x.jpg')],
        local: const {},
      );

      expect(plan.discoverersToApply.map((c) => c.spotId), ['a']);
      expect(plan.thumbsToFetch.map((c) => c.spotId), ['a']);
    });

    test('thumbPath がないクリアのサムネは取得しない (プレースホルダを表示する)', () {
      final plan = planClearSync(clears: [clear('a', 'x')], local: const {});

      expect(plan.thumbsToFetch, isEmpty);
    });

    test('全部そろっていれば何もしない', () {
      final plan = planClearSync(
        clears: [clear('a', 'x', thumbPath: 'p')],
        local: {'a': const LocalClearState(discovererUid: 'x', hasThumb: true)},
      );

      expect(plan.isEmpty, isTrue);
    });
  });

  group('rankDiscoverers', () {
    test('発見数の多い順に並べ、同数なら入室順にする', () {
      final ranking = rankDiscoverers(
        clears: [
          clear('a', 'y'),
          clear('b', 'x'),
          clear('c', 'y'),
          clear('d', 'z'),
        ],
        uidsInJoinOrder: ['x', 'y', 'z', 'w'],
      );

      expect(ranking.map((e) => (e.uid, e.count)), [
        ('y', 2),
        ('x', 1),
        ('z', 1),
        ('w', 0),
      ]);
    });
  });

  group('hasAllClearThumbs', () {
    test('すべてのクリアの発見者のサムネが端末にあれば true', () {
      expect(
        hasAllClearThumbs(
          clears: [clear('a', 'x', thumbPath: 'p'), clear('b', 'me')],
          local: {
            'a': const LocalClearState(discovererUid: 'x', hasThumb: true),
            // 自分の発見は、thumbPath がまだなくても端末にサムネがある
            'b': const LocalClearState(discovererUid: 'me', hasThumb: true),
          },
        ),
        isTrue,
      );
    });

    test('サムネがまだ届いていないクリアがあれば false', () {
      expect(
        hasAllClearThumbs(
          clears: [clear('a', 'x')],
          local: {
            'a': const LocalClearState(discovererUid: 'x', hasThumb: false),
          },
        ),
        isFalse,
      );
    });

    test('端末の発見者がサーバと違えば false', () {
      expect(
        hasAllClearThumbs(
          clears: [clear('a', 'x', thumbPath: 'p')],
          local: {
            'a': const LocalClearState(discovererUid: 'me', hasThumb: true),
          },
        ),
        isFalse,
      );
    });
  });
}
