import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/router.dart';

/// [location] へ `go` したときに積まれる画面のパス (下から順)
List<String> _stack(String location) =>
    appRouter.configuration
        .findMatch(Uri.parse(location))
        .matches
        .whereType<RouteMatch>()
        .map((m) => m.matchedLocation)
        .toList();

void main() {
  group('appRouter', () {
    // 戻ると「みんなで」に出ると、その下に画面がなく、戻るボタンが消えてアプリが閉じる
    for (final location in ['/coop/lobby', '/coop/mission', '/coop/result']) {
      test('$location へ移ると、その下はホームになる', () {
        expect(_stack(location), ['/', location]);
      });
    }

    test('「ルームに入る」は「みんなで」の上に積む', () {
      expect(_stack('/coop/join'), ['/coop', '/coop/join']);
    });
  });
}
