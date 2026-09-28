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
    DateTime at(int minute) => DateTime.utc(2026, 9, 29, 10, minute);

    test('重複した名前には、名前を付けた順 (基本は入室順) に番号を付ける', () {
      final names = displayNicknames([
        (uid: 'a', nickname: 'たろう', namedAt: at(0)),
        (uid: 'b', nickname: 'はなこ', namedAt: at(1)),
        (uid: 'c', nickname: 'たろう', namedAt: at(2)),
        (uid: 'd', nickname: 'たろう', namedAt: at(3)),
      ]);

      expect(names, {'a': 'たろう', 'b': 'はなこ', 'c': 'たろう(2)', 'd': 'たろう(3)'});
    });

    test('先に入室した人があとから同じ名前に変えたら、その人に番号が付く', () {
      final names = displayNicknames([
        (uid: 'host', nickname: 'はなこ', namedAt: at(5)), // 入室は 0 分、5 分に名前を変えた
        (uid: 'guest', nickname: 'はなこ', namedAt: at(3)), // 3 分に名前を変えた
      ]);

      expect(names, {'host': 'はなこ(2)', 'guest': 'はなこ'});
    });

    test('名前を付けた時刻が分からない人がいれば、並び順 (入室順) のまま付ける', () {
      final names = displayNicknames([
        (uid: 'a', nickname: 'たろう', namedAt: null),
        (uid: 'b', nickname: 'たろう', namedAt: at(0)),
      ]);

      expect(names, {'a': 'たろう', 'b': 'たろう(2)'});
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
