import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/presentation/util/mission_format_util.dart';

void main() {
  group('formatMissionDuration', () {
    test('時間・分・秒で表す', () {
      final start = DateTime(2026, 9, 23, 14);
      expect(
        formatMissionDuration(
          start,
          start.add(const Duration(hours: 1, minutes: 12, seconds: 40)),
        ),
        '1時間12分40秒',
      );
      expect(
        formatMissionDuration(
          start,
          start.add(const Duration(minutes: 48, seconds: 5)),
        ),
        '48分5秒',
      );
      expect(
        formatMissionDuration(start, start.add(const Duration(seconds: 40))),
        '40秒',
      );
    });

    test('omitSeconds なら秒を省く (1 分未満なら秒)', () {
      final start = DateTime(2026, 9, 23, 14);
      expect(
        formatMissionDuration(
          start,
          start.add(const Duration(hours: 1, minutes: 12, seconds: 40)),
          omitSeconds: true,
        ),
        '1時間12分',
      );
      expect(
        formatMissionDuration(
          start,
          start.add(const Duration(minutes: 48, seconds: 5)),
          omitSeconds: true,
        ),
        '48分',
      );
      expect(
        formatMissionDuration(
          start,
          start.add(const Duration(seconds: 40)),
          omitSeconds: true,
        ),
        '40秒',
      );
    });
  });
}
