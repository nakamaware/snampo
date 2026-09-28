import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/presentation/component/nickname_sheet.dart';
import 'package:snampo/features/settings/presentation/store/nickname_store.dart';

void main() {
  final auto = SavedNickname(Nickname.parse('プレイヤー6916'), isAuto: true);

  Future<Future<SavedNickname?>> open(
    WidgetTester tester, {
    SavedNickname? current,
    Future<String?> Function(SavedNickname saved)? onSave,
    String? Function(String name)? duplicateWarning,
  }) async {
    late Future<SavedNickname?> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () =>
                        result = showNicknameSheet(
                          context,
                          current: current ?? auto,
                          helperText: 'ルームのメンバーに表示されます',
                          onSave: onSave,
                          duplicateWarning: duplicateWarning,
                        ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  FilledButton saveButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  testWidgets('入力した名前を、自分で付けた名前として返す', (tester) async {
    final result = await open(tester);

    await tester.enterText(find.byType(TextField), ' たろう ');
    await tester.pump();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(await result, SavedNickname(Nickname.parse('たろう'), isAuto: false));
  });

  testWidgets('空欄と、今の名前のままでは保存できない', (tester) async {
    await open(tester);

    expect(saveButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  ');
    await tester.pump();
    expect(find.text('名前を入力してください'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('🎲 で決めた名前は、おまかせとして返す', (tester) async {
    final result = await open(
      tester,
      current: SavedNickname(Nickname.parse('たろう'), isAuto: false),
    );

    await tester.tap(find.byTooltip('おまかせで決める'));
    await tester.pump();
    final name =
        tester.widget<TextField>(find.byType(TextField)).controller!.text;
    expect(name, startsWith('プレイヤー'));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(await result, SavedNickname(Nickname.parse(name), isAuto: true));
  });

  testWidgets('ほかのメンバーと同じ名前なら、注意を出す', (tester) async {
    await open(
      tester,
      duplicateWarning: (name) => name == 'たろう' ? '同じ名前です' : null,
    );

    await tester.enterText(find.byType(TextField), 'たろう');
    await tester.pump();

    expect(find.text('同じ名前です'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('保存に失敗したら、シートを開いたままエラーを出す', (tester) async {
    final saved = <SavedNickname>[];
    final result = await open(
      tester,
      onSave: (value) async {
        saved.add(value);
        return saved.length == 1 ? '名前を変えられませんでした' : null;
      },
    );

    await tester.enterText(find.byType(TextField), 'たろう');
    await tester.pump();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('名前を変えられませんでした'), findsOneWidget);
    expect(find.text('名前を変える'), findsOneWidget);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('名前を変える'), findsNothing);
    expect(await result, SavedNickname(Nickname.parse('たろう'), isAuto: false));
  });
}
