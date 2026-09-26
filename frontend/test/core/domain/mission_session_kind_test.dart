import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';

void main() {
  group('MissionSessionKind.persistKey', () {
    test('ソロは以前と同じキーを使う (既存データをそのまま読める)', () {
      expect(
        MissionSessionKind.solo.persistKey('PersistedMission'),
        'PersistedMission',
      );
    });

    test('協力プレイはソロと別のキーを使う', () {
      expect(
        MissionSessionKind.coop.persistKey('PersistedMission'),
        'PersistedMission.coop',
      );
    });
  });
}
