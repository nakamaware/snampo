import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';

void main() {
  group('Nickname', () {
    test('空欄なら「プレイヤー」と 4 桁の数字で自動で命名する', () {
      final nickname = Nickname.orAuto('  ', Random(1));

      expect(nickname.value, matches(RegExp(r'^プレイヤー\d{4}$')));
    });

    test('前後の空白を除いて保持する', () {
      expect(Nickname.orAuto(' たろう ', Random(1)).value, 'たろう');
    });

    test('長すぎる名前は上限の文字数で切る', () {
      final nickname = Nickname.orAuto('あ' * 40, Random(1));

      expect(nickname.value.length, Nickname.maxLength);
    });
  });

  group('Nickname.parse', () {
    test('保存済みの値から復元する', () {
      expect(Nickname.parse('たろう').value, 'たろう');
    });

    test('空欄や長すぎる値は FormatException (自動で命名はしない)', () {
      expect(() => Nickname.parse('  '), throwsFormatException);
      expect(
        () => Nickname.parse('あ' * (Nickname.maxLength + 1)),
        throwsFormatException,
      );
    });
  });

  group('NicknameConverter', () {
    test('JSON の文字列と相互変換できる', () {
      const converter = NicknameConverter();
      final nickname = Nickname.parse('たろう');

      expect(converter.fromJson(converter.toJson(nickname)), nickname);
    });
  });

  group('displayNicknames', () {
    test('重複した名前には入室順に番号を付ける', () {
      final names = displayNicknames([
        (uid: 'a', nickname: 'たろう'),
        (uid: 'b', nickname: 'はなこ'),
        (uid: 'c', nickname: 'たろう'),
        (uid: 'd', nickname: 'たろう'),
      ]);

      expect(names, {'a': 'たろう', 'b': 'はなこ', 'c': 'たろう(2)', 'd': 'たろう(3)'});
    });
  });

  group('discovererLabel', () {
    test('発見者がいれば「発見: 名前」', () {
      expect(discovererLabel('たろう(2)'), '発見: たろう(2)');
    });

    test('発見者がいなければ「未クリア」', () {
      expect(discovererLabel(null), '未クリア');
    });

    test('クリア済みで発見者が分からなければ、取得できなかったと表示する', () {
      expect(discovererLabel(null, isCleared: true), '発見者: 取得できませんでした');
    });
  });
}
