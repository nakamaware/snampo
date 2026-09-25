import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';

void main() {
  test('一覧の日付は、月日・曜日・時刻にする', () {
    expect(formatHistoryDate(DateTime(2026, 9, 23, 14, 5)), '9月23日 (水) 14:05');
    expect(formatHistoryMonth(DateTime(2026, 9, 23)), '2026年9月');
  });
}
