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

  group('isNumberedNickname', () {
    DateTime at(int minute) => DateTime.utc(2026, 9, 29, 10, minute);

    test('あとから同じ名前にした人だけが、番号付きになる', () {
      final members = <NamedMember>[
        (uid: 'host', nickname: 'たろう', namedAt: at(5)), // 5 分に同じ名前に変えた
        (uid: 'guest', nickname: 'たろう', namedAt: at(3)),
        (uid: 'other', nickname: 'はなこ', namedAt: at(1)),
      ];
      final names = displayNicknames(members);

      expect(
        [for (final m in members) isNumberedNickname(names, m)],
        [true, false, false],
      );
    });

    test('もともと「(2)」の入った名前でも、重複しなければ番号付きにならない', () {
      final members = <NamedMember>[
        (uid: 'a', nickname: 'たろう(2)', namedAt: at(0)),
      ];

      expect(
        isNumberedNickname(displayNicknames(members), members.single),
        isFalse,
      );
    });
  });

  group('SavedNickname', () {
    final auto = SavedNickname(Nickname.parse('プレイヤー1234'), isAuto: true);

    test('空欄の入力ならおまかせの名前を作る', () {
      final saved = SavedNickname.fromInput('  ', previous: auto);
      expect(saved.isAuto, isTrue);
      expect(saved.nickname.hasAutoFormat, isTrue);
    });

    test('保存済みのおまかせの名前をそのまま保存したら、おまかせのまま', () {
      expect(SavedNickname.fromInput(' プレイヤー1234 ', previous: auto), auto);
    });

    test('名前を変えたら、おまかせではなくなる', () {
      expect(
        SavedNickname.fromInput('たろう', previous: auto),
        SavedNickname(Nickname.parse('たろう'), isAuto: false),
      );
    });

    test('自分で付けた名前は、同じ名前で保存してもおまかせにならない', () {
      final custom = SavedNickname(Nickname.parse('プレイヤー1234'), isAuto: false);
      expect(
        SavedNickname.fromInput('プレイヤー1234', previous: custom).isAuto,
        isFalse,
      );
    });

    test('ルームでの名前が、この端末で付けたおまかせの名前のままか', () {
      expect(auto.isAutoIn('プレイヤー1234'), isTrue);
      expect(auto.isAutoIn('たろう'), isFalse);
      expect(auto.isAutoIn(null), isFalse);
    });
  });

  group('duplicateNicknameWarning', () {
    DateTime at(int minute) => DateTime.utc(2026, 9, 29, 10, minute);
    final members = <NamedMember>[
      (uid: 'host', nickname: 'たろう', namedAt: at(0)),
      (uid: 'me', nickname: 'はなこ', namedAt: at(1)),
    ];

    test('同じ名前の人がいれば、あとから同じ名前にした自分に付く番号を示す', () {
      expect(
        duplicateNicknameWarning(
          name: 'たろう',
          myUid: 'me',
          members: members,
          now: at(5),
        ),
        '「たろう」さんと同じ名前です。あなたは「たろう(2)」と表示されます',
      );
    });

    test('同じ名前の人がいなければ null (自分の今の名前は数えない)', () {
      expect(
        duplicateNicknameWarning(
          name: 'はなこ',
          myUid: 'me',
          members: members,
          now: at(5),
        ),
        isNull,
      );
      expect(
        duplicateNicknameWarning(
          name: 'じろう',
          myUid: 'me',
          members: members,
          now: at(5),
        ),
        isNull,
      );
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
