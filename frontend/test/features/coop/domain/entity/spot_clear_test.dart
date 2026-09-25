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
          spot('a'): const LocalClearState(discovererUid: 'x', hasThumb: true),
          spot('c'): const LocalClearState(discovererUid: 'z', hasThumb: false),
        },
      );

      expect(plan.discoverersToApply.map((c) => c.spotId.value), ['b']);
      expect(plan.thumbsToFetch.map((c) => c.spotId.value), ['b', 'c']);
    });

    test('新しく知ったクリアのサムネも取得する', () {
      final plan = planClearSync(
        clears: [clear('a', 'x', thumbPath: 'rooms/R/thumbs/a/x.jpg')],
        local: const {},
      );

      expect(plan.discoverersToApply.map((c) => c.spotId.value), ['a']);
      expect(plan.thumbsToFetch.map((c) => c.spotId.value), ['a']);
    });

    test('全部そろっていれば何もしない', () {
      final plan = planClearSync(
        clears: [clear('a', 'x', thumbPath: 'p')],
        local: {
          spot('a'): const LocalClearState(discovererUid: 'x', hasThumb: true),
        },
      );

      expect(plan.discoverersToApply, isEmpty);
      expect(plan.thumbsToFetch, isEmpty);
    });
  });

  group('hasAllClearThumbs', () {
    test('すべてのクリアの発見者のサムネが端末にあれば true', () {
      expect(
        hasAllClearThumbs(
          clears: [clear('a', 'x', thumbPath: 'p'), clear('b', 'me')],
          local: {
            spot('a'): const LocalClearState(
              discovererUid: 'x',
              hasThumb: true,
            ),
            spot('b'): const LocalClearState(
              discovererUid: 'me',
              hasThumb: true,
            ),
          },
        ),
        isTrue,
      );
    });

    test('クリアが 0 件なら true (finished のあとにクリアは作れないため、待つものがない)', () {
      expect(hasAllClearThumbs(clears: const [], local: const {}), isTrue);
    });

    test('サムネがまだ届いていないクリアがあれば false', () {
      expect(
        hasAllClearThumbs(
          clears: [clear('a', 'x')],
          local: {
            spot('a'): const LocalClearState(
              discovererUid: 'x',
              hasThumb: false,
            ),
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
            spot('a'): const LocalClearState(
              discovererUid: 'me',
              hasThumb: true,
            ),
          },
        ),
        isFalse,
      );
    });
  });
}
