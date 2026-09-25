import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/history/data/database/history_database.dart';

/// v4 で `mission_histories` に足した列
const _v4HistoryColumns = [
  'room_code',
  'coop_sync_state',
  'coop_is_host',
  'coop_members',
  'coop_expires_at',
  'coop_delete_at',
];

/// v4 で `history_spots` に足した列
const _v4SpotColumns = [
  'zoom_level',
  'spot_id',
  'discoverer_uid',
  'discoverer_nickname',
  'discoverer_thumb_path',
  'discoverer_judge_rank',
  'discoverer_distance_error_meters',
  'discoverer_heading_error_degrees',
  'discoverer_guess_lat',
  'discoverer_guess_lng',
  'discoverer_captured_heading',
  'discoverer_zoom_level',
  'is_cleared',
];

void main() {
  late File file;

  /// 新しく作った DB の列 (テーブルごと)
  late Map<String, List<String>> freshColumns;

  Future<List<String>> columns(HistoryDatabase db, String table) async => [
    for (final row in await db.customSelect('PRAGMA table_info($table)').get())
      row.read<String>('name'),
  ];

  Future<Map<String, List<String>>> allColumns(HistoryDatabase db) async => {
    for (final table in ['mission_histories', 'history_spots'])
      table: await columns(db, table),
  };

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('history_db_test');
    addTearDown(() => dir.delete(recursive: true));
    file = File('${dir.path}/history.db');
    // 今の版の DB を作っておく
    final db = HistoryDatabase(NativeDatabase(file));
    freshColumns = await allColumns(db);
    await db.close();
  });

  /// 開く直前に [breakDb] で DB (sqlite3 の Database) を崩してから開き、移行を済ませる
  Future<HistoryDatabase> reopen(DatabaseSetup breakDb) async {
    final db = HistoryDatabase(NativeDatabase(file, setup: breakDb));
    addTearDown(db.close);
    // 最初の問い合わせで移行が走る
    await db.customSelect('SELECT 1').get();
    return db;
  }

  /// v4 で足した列を落として v3 (main でリリース済みの版) の DB にし、[statements] を実行する
  ///
  /// [keepSpotColumns] は、落とさずに残す `history_spots` の列の数 (移行の途中を再現する)。
  DatabaseSetup asV3({
    int keepSpotColumns = 0,
    List<String> statements = const [],
  }) => (raw) {
    for (final column in _v4HistoryColumns) {
      raw.execute('ALTER TABLE mission_histories DROP COLUMN $column');
    }
    for (final column in _v4SpotColumns.skip(keepSpotColumns)) {
      raw.execute('ALTER TABLE history_spots DROP COLUMN $column');
    }
    raw.execute('PRAGMA user_version = 3');
    statements.forEach(raw.execute);
  };

  group('HistoryDatabase の移行', () {
    test('v3 の DB を、1 回の移行で今の版の列にする (履歴は残り、クリア済みになる)', () async {
      final db = await reopen(
        asV3(
          statements: [
            '''
INSERT INTO mission_histories
  (id, completed_at, started_at, departure_lat, departure_lng, overview_polyline, radius_meters)
VALUES ('h1', 2, 1, 35, 139, 'p', 1000)
''',
            '''
INSERT INTO history_spots
  (history_id, sort_order, is_destination, lat, lng, street_view_image_path)
VALUES ('h1', 0, 1, 35, 139, '/sv.jpg')
''',
          ],
        ),
      );

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 4);
      expect(await allColumns(db), freshColumns);
      final spot =
          await db
              .customSelect('SELECT is_cleared FROM history_spots')
              .getSingle();
      expect(spot.read<int>('is_cleared'), 1);
      final history =
          await db
              .customSelect('SELECT mode FROM mission_histories')
              .getSingle();
      expect(history.read<String>('mode'), 'random');
    });

    test('版だけが古く、列はすでにある DB も開ける (古いアプリで開き直したときなど)', () async {
      final db = await reopen((raw) {
        raw.execute('PRAGMA user_version = 3');
      });

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 4);
      expect(await allColumns(db), freshColumns);
    });

    test('移行が途中で止まった DB も、足りない列を足して開ける', () async {
      // 最初の 1 列だけが足された状態 (移行の途中でアプリが落ちた) を作る
      final db = await reopen(asV3(keepSpotColumns: 1));

      expect(await allColumns(db), freshColumns);
    });
  });
}
