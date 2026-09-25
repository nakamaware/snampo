import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';

void main() {
  test('一覧の日付は、月日・曜日・時刻にする', () {
    expect(formatHistoryDate(DateTime(2026, 9, 23, 14, 5)), '9月23日 (水) 14:05');
    expect(formatHistoryMonth(DateTime(2026, 9, 23)), '2026年9月');
  });

  test('一覧のかかった時間は、秒を省く (1 分未満なら秒)', () {
    final start = DateTime(2026, 9, 23, 14);
    expect(
      formatMissionDurationShort(
        start,
        start.add(const Duration(hours: 1, minutes: 12, seconds: 40)),
      ),
      '1時間12分',
    );
    expect(
      formatMissionDurationShort(
        start,
        start.add(const Duration(minutes: 48, seconds: 5)),
      ),
      '48分',
    );
    expect(
      formatMissionDurationShort(start, start.add(const Duration(seconds: 40))),
      '40秒',
    );
  });
}
