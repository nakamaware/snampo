import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'history_database.g.dart';

/// 完了ミッション履歴のメタ情報 (1 行 = 1 履歴)
@DataClassName('MissionHistoryRow')
class MissionHistories extends Table {
  /// 履歴レコード ID (UUID)
  TextColumn get id => text()();

  /// 完了日時 (Unix ms)
  IntColumn get completedAt => integer()();

  /// 開始日時 (Unix ms)
  IntColumn get startedAt => integer()();

  /// 出発地緯度
  RealColumn get departureLat => real()();

  /// 出発地経度
  RealColumn get departureLng => real()();

  /// ルート概要のエンコード済みポリライン
  TextColumn get overviewPolyline => text()();

  /// 探索半径 (m)。目的地指定モードでは null
  IntColumn get radiusMeters => integer().nullable()();

  /// ミッション開始モード: `random` / `destination`
  TextColumn get mode => text().withDefault(const Constant('random'))();

  /// ユーザーが指定した目的地の緯度 (ランダムモードでは null)
  RealColumn get destinationLat => real().nullable()();

  /// ユーザーが指定した目的地の経度 (ランダムモードでは null)
  RealColumn get destinationLng => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 経由地・目的地スポット 1 件
@DataClassName('HistorySpotRow')
class HistorySpots extends Table {
  /// 行 ID (自動採番)
  IntColumn get id => integer().autoIncrement()();

  /// [MissionHistories.id] への外部キー
  TextColumn get historyId =>
      text().references(MissionHistories, #id, onDelete: KeyAction.cascade)();

  /// 経路順 (0 始まり、最後が目的地)
  IntColumn get sortOrder => integer()();

  /// 目的地なら 1、経由地なら 0
  IntColumn get isDestination => integer()();

  /// スポット緯度
  RealColumn get lat => real()();

  /// スポット経度
  RealColumn get lng => real()();

  /// Street View 画像ファイルの絶対パス
  TextColumn get streetViewImagePath => text()();

  /// ユーザー撮影写真のパス (あれば)
  TextColumn get userPhotoPath => text().nullable()();

  /// チェックポイント達成日時 (Unix ms)
  IntColumn get achievedAt => integer().nullable()();
}

/// 履歴専用 Drift DB (`snampo_history.db`)
@DriftDatabase(tables: [MissionHistories, HistorySpots])
class HistoryDatabase extends _$HistoryDatabase {
  /// [HistoryDatabase] を作成する
  HistoryDatabase([QueryExecutor? executor])
    : super(executor ?? openHistoryConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await customStatement('''
ALTER TABLE mission_histories ADD COLUMN mode TEXT NOT NULL DEFAULT 'random'
''');
        await customStatement(
          'ALTER TABLE mission_histories ADD COLUMN destination_lat REAL',
        );
        await customStatement(
          'ALTER TABLE mission_histories ADD COLUMN destination_lng REAL',
        );
        await customStatement('''
UPDATE mission_histories SET mode = 'destination'
WHERE radius_meters IS NULL
''');
        await customStatement('''
UPDATE mission_histories SET destination_lat = (
  SELECT lat FROM history_spots
  WHERE history_spots.history_id = mission_histories.id
  AND history_spots.is_destination = 1
), destination_lng = (
  SELECT lng FROM history_spots
  WHERE history_spots.history_id = mission_histories.id
  AND history_spots.is_destination = 1
) WHERE mode = 'destination'
''');
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}

/// ドキュメントディレクトリに `snampo_history.db` を開く
LazyDatabase openHistoryConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final documentsDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(documentsDir.path, 'snampo_history.db'));
    return NativeDatabase.createInBackground(file);
  });
}
