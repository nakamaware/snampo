import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';

void main() {
  group('RoomCode', () {
    test('生成したコードは紛らわしい文字を含まない英数字大文字 6 文字', () {
      final random = Random(1);
      for (var i = 0; i < 200; i++) {
        final code = RoomCode.generate(random).value;
        expect(code, hasLength(6));
        expect(code, matches(RegExp(r'^[A-Z2-9]{6}$')));
        expect(code, isNot(matches(RegExp('[0O1IL]'))));
      }
    });

    test('入力は前後の空白を除き、大文字にしてから検証する', () {
      expect(RoomCode.tryParse(' abcd23 ')?.value, 'ABCD23');
    });

    test('紛らわしい文字や長さの違うコードは不正', () {
      expect(RoomCode.tryParse('ABCDO2'), isNull);
      expect(RoomCode.tryParse('ABCD21'), isNull);
      expect(RoomCode.tryParse('ABCD2'), isNull);
      expect(RoomCode.tryParse('ABCD234'), isNull);
      expect(RoomCode.tryParse('ABCD-2'), isNull);
    });

    test('QR の文字列と相互変換できる', () {
      final code = RoomCode.tryParse('ABCD23')!;
      expect(code.toQrPayload(), 'snampo:room:ABCD23');
      expect(RoomCode.fromQrPayload('snampo:room:ABCD23'), code);
    });

    test('スナんぽ用でない QR は読み取らない', () {
      expect(RoomCode.fromQrPayload('https://example.com'), isNull);
      expect(RoomCode.fromQrPayload('snampo:room:ABCDO2'), isNull);
      expect(RoomCode.fromQrPayload('ABCD23'), isNull);
    });
  });
}
