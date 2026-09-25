import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/history/data/database/history_database.dart';

/// v5 で足した列
const _v5Columns = [
  'discoverer_judge_rank',
  'discoverer_distance_error_meters',
  'discoverer_heading_error_degrees',
  'discoverer_guess_lat',
  'discoverer_guess_lng',
  'discoverer_captured_heading',
];

void main() {
  late File file;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('history_db_test');
    addTearDown(() => dir.delete(recursive: true));
    file = File('${dir.path}/history.db');
    // 今の版 (v5) の DB を作っておく
    final db = HistoryDatabase(NativeDatabase(file));
    await db.customSelect('SELECT 1').get();
    await db.close();
  });

  /// 開く直前に [breakDb] で DB を崩してから開き、移行を済ませる
  Future<HistoryDatabase> reopen(void Function(dynamic raw) breakDb) async {
    final db = HistoryDatabase(NativeDatabase(file, setup: breakDb));
    addTearDown(db.close);
    // 最初の問い合わせで移行が走る
    await db.customSelect('SELECT 1').get();
    return db;
  }

  Future<List<String>> columns(HistoryDatabase db) async => [
    for (final row
        in await db.customSelect('PRAGMA table_info(history_spots)').get())
      row.read<String>('name'),
  ];

  group('HistoryDatabase の移行', () {
    test('版だけが古く、列はすでにある DB も開ける (古いアプリで開き直したときなど)', () async {
      final db = await reopen((raw) {
        // ignore: avoid_dynamic_calls
        raw.execute('PRAGMA user_version = 4');
      });

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 5);
      expect(await columns(db), containsAll(_v5Columns));
    });

    test('移行が途中で止まった DB も、足りない列を足して開ける', () async {
      final db = await reopen((raw) {
        // v5 の列のうち最初の 1 つだけが足された状態 (移行の途中でアプリが落ちた) を作る
        for (final column in _v5Columns.skip(1)) {
          // ignore: avoid_dynamic_calls
          raw.execute('ALTER TABLE history_spots DROP COLUMN $column');
        }
        // ignore: avoid_dynamic_calls
        raw.execute('PRAGMA user_version = 4');
      });

      expect(await columns(db), containsAll(_v5Columns));
    });
  });
}
