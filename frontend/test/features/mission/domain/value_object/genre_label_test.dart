import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/domain/value_object/genre_label.dart';

void main() {
  group('GenreLabel', () {
    test('Google の snake_case を日本語にする', () {
      expect('park'.japaneseLabel, '公園');
      expect('cafe'.japaneseLabel, 'カフェ');
    });

    test('Apple の PascalCase も日本語にする', () {
      expect('Park'.japaneseLabel, '公園');
      expect('ReligiousSite'.japaneseLabel, '神社・寺院');
      expect('religious_site'.japaneseLabel, '神社・寺院');
    });

    test('未知の値はそのまま返す', () {
      expect('unknown_place'.japaneseLabel, 'unknown_place');
    });
  });
}
