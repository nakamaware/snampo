import 'package:flutter_test/flutter_test.dart';
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
    test('trim したコードを保持する', () {
      expect(RoomCode('  AB12  ').value, 'AB12');
    });

    test('空と内部空白で ArgumentError', () {
      expect(() => RoomCode(''), throwsA(isA<ArgumentError>()));
      expect(() => RoomCode('AB 12'), throwsA(isA<ArgumentError>()));
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
