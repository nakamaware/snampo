import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/settings/presentation/store/nickname_store.dart';

void main() {
  group('isAutoInput', () {
    final auto = SavedNickname(Nickname.parse('プレイヤー1234'), isAuto: true);

    test('空欄ならおまかせ', () {
      expect(isAutoInput('  ', auto), isTrue);
      expect(isAutoInput('', null), isTrue);
    });

    test('保存済みのおまかせの名前をそのまま保存したら、おまかせのまま', () {
      expect(isAutoInput(' プレイヤー1234 ', auto), isTrue);
    });

    test('名前を変えたら、おまかせではなくなる', () {
      expect(isAutoInput('たろう', auto), isFalse);
    });

    test('自分で付けた名前は、同じ名前で保存してもおまかせにならない', () {
      final custom = SavedNickname(Nickname.parse('プレイヤー1234'), isAuto: false);
      expect(isAutoInput('プレイヤー1234', custom), isFalse);
    });
  });

  group('decodeSavedNickname', () {
    test('名前とおまかせかを復元する', () {
      expect(
        decodeSavedNickname('{"value":"たろう","isAuto":false}'),
        SavedNickname(Nickname.parse('たろう'), isAuto: false),
      );
      expect(
        decodeSavedNickname('{"value":"プレイヤー0382","isAuto":true}'),
        SavedNickname(Nickname.parse('プレイヤー0382'), isAuto: true),
      );
    });

    test('以前の形式 (名前の文字列だけ) は、自動命名の形式ならおまかせとみなす', () {
      expect(decodeSavedNickname('"プレイヤー1234"').isAuto, isTrue);
      expect(decodeSavedNickname('"たろう"').isAuto, isFalse);
      expect(decodeSavedNickname('"プレイヤー"').isAuto, isFalse);
    });

    test('以前の未設定 (null) なら、おまかせの名前を作る', () {
      final saved = decodeSavedNickname('null');
      expect(saved.isAuto, isTrue);
      expect(saved.nickname.value, startsWith('プレイヤー'));
    });
  });
}
