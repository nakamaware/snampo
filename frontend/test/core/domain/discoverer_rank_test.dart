import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/discoverer_rank.dart';

void main() {
  group('rankDiscoverers', () {
    test('発見数の多い順に並べ、同数なら入室順にする', () {
      final ranking = rankDiscoverers(
        discovererUids: ['y', 'x', 'y', 'z'],
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
}
