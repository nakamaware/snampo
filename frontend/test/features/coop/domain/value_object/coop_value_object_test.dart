import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/value_object/clear_thumb.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';

void main() {
  group('PlayerId', () {
    test('trim した uid を保持する', () {
      expect(PlayerId('  abc  ').value, 'abc');
    });

    test('空文字で ArgumentError', () {
      expect(() => PlayerId(''), throwsA(isA<ArgumentError>()));
      expect(() => PlayerId('   '), throwsA(isA<ArgumentError>()));
    });
  });

  group('RoomCode', () {
    test('前後の空白を除いた数字 6 桁を保持する', () {
      expect(RoomCode('  012345  ').value, '012345');
    });

    test('6 桁以外で ArgumentError', () {
      expect(() => RoomCode(''), throwsA(isA<ArgumentError>()));
      expect(() => RoomCode('12345'), throwsA(isA<ArgumentError>()));
      expect(() => RoomCode('1234567'), throwsA(isA<ArgumentError>()));
      expect(() => RoomCode('12345a'), throwsA(isA<ArgumentError>()));
      expect(() => RoomCode('AB12'), throwsA(isA<ArgumentError>()));
    });

    test('generate は数字 6 桁', () {
      final code = RoomCode.generate(Random(1));
      expect(RegExp(r'^\d{6}$').hasMatch(code.value), isTrue);
    });
  });

  group('Nickname', () {
    test('trim した名前を保持する', () {
      expect(Nickname('  はな  ').value, 'はな');
    });

    test('空で ArgumentError', () {
      expect(() => Nickname(''), throwsA(isA<ArgumentError>()));
      expect(() => Nickname('   '), throwsA(isA<ArgumentError>()));
    });
  });

  group('ClearThumb', () {
    test('Storage パスは rooms/{code}/thumbs/{spot}.jpg', () {
      final thumb = ClearThumb(
        roomCode: RoomCode('123456'),
        spotId: SpotId.fromIndex(2),
      );

      expect(thumb.objectPath, 'rooms/123456/thumbs/2.jpg');
    });
  });

  group('SpotId', () {
    test('index 0 は文字列 0', () {
      expect(SpotId.fromIndex(0).value, '0');
      expect(SpotId.fromIndex(0).index, 0);
    });

    test('parse は先頭ゼロを拒否する', () {
      expect(() => SpotId.parse('01'), throwsA(isA<ArgumentError>()));
    });

    test('負の index で ArgumentError', () {
      expect(() => SpotId.fromIndex(-1), throwsA(isA<ArgumentError>()));
      expect(() => SpotId.parse('-1'), throwsA(isA<ArgumentError>()));
    });
  });
}
