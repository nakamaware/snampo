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

  /// ミッション開始モード: `random` / `destination` / `coop`
  ///
  /// `coop` のときのミッション設定は [radiusMeters] (random) か
  /// [destinationLat] / [destinationLng] (destination) から判定する。
  TextColumn get mode => text().withDefault(const Constant('random'))();

  /// ユーザーが指定した目的地の緯度 (ランダムモードでは null)
  RealColumn get destinationLat => real().nullable()();

  /// ユーザーが指定した目的地の経度 (ランダムモードでは null)
  RealColumn get destinationLng => real().nullable()();

  /// 協力プレイのルームコード (ソロでは null)。協力プレイの履歴はこれをキーに upsert する
  TextColumn get roomCode => text().nullable()();

  /// 協力プレイの同期の状態: `inProgress` (進行中) / `finalized` (確定)
  TextColumn get coopSyncState => text().nullable()();

  /// 自分がホストだったか (1 / 0)
  IntColumn get coopIsHost => integer().nullable()();

  /// 協力プレイのメンバー一覧 (`[{"uid": ..., "nickname": ...}]` の JSON)
  TextColumn get coopMembers => text().nullable()();

  /// 協力プレイの遊べる期限 (Unix ms)
  IntColumn get coopExpiresAt => integer().nullable()();

  /// 協力プレイのデータの保持期限 (Unix ms)
  IntColumn get coopDeleteAt => integer().nullable()();

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

  /// スポット名称 (Places API)
  TextColumn get name => text().nullable()();

  /// ジャンル識別子 (Places primaryType)
  TextColumn get genre => text().nullable()();

  /// Google Maps の詳細 URL
  TextColumn get googleMapsUrl => text().nullable()();

  /// 正解画像の基準方角 (度)
  RealColumn get referenceHeading => real().nullable()();

  /// 採点ランク (`excellent` / `good` / `fair` / `miss`)
  ///
  /// 旧バージョンで保存された `retry` は読み込み時に `miss` として扱う。
  TextColumn get judgeRank => text().nullable()();

  /// 位置誤差 (m)
  RealColumn get distanceErrorMeters => real().nullable()();

  /// 方角誤差 (度)
  RealColumn get headingErrorDegrees => real().nullable()();

  /// 撮影時の推定緯度
  RealColumn get guessLat => real().nullable()();

  /// 撮影時の推定経度
  RealColumn get guessLng => real().nullable()();

  /// 撮影時の方角 (度)
  RealColumn get capturedHeading => real().nullable()();

  /// スポット ID (place_id / geo URI)。旧データでは null
  TextColumn get spotId => text().nullable()();

  /// 協力プレイの発見者の uid
  TextColumn get discovererUid => text().nullable()();

  /// 協力プレイの発見者のニックネーム (発見時点)
  TextColumn get discovererNickname => text().nullable()();

  /// 協力プレイの発見者のサムネのパス
  TextColumn get discovererThumbPath => text().nullable()();

  /// 協力プレイの発見者の採点ランク (`excellent` / `good` / `fair` / `miss`)
  TextColumn get discovererJudgeRank => text().nullable()();

  /// 協力プレイの発見者の位置誤差 (m)
  RealColumn get discovererDistanceErrorMeters => real().nullable()();

  /// 協力プレイの発見者の方角誤差 (度)
  RealColumn get discovererHeadingErrorDegrees => real().nullable()();

  /// 協力プレイの発見者が撮影した緯度
  RealColumn get discovererGuessLat => real().nullable()();

  /// 協力プレイの発見者が撮影した経度
  RealColumn get discovererGuessLng => real().nullable()();

  /// 協力プレイの発見者が撮影したときの方角 (度)
  RealColumn get discovererCapturedHeading => real().nullable()();

  /// クリア済みなら 1 (協力プレイの途中終了では未クリアのスポットがある)
  IntColumn get isCleared => integer().withDefault(const Constant(1))();
}

/// 履歴専用 Drift DB (`snampo_history.db`)
@DriftDatabase(tables: [MissionHistories, HistorySpots])
class HistoryDatabase extends _$HistoryDatabase {
  /// [HistoryDatabase] を作成する
  HistoryDatabase([QueryExecutor? executor])
    : super(executor ?? openHistoryConnection());

  @override
  int get schemaVersion => 5;

  /// [table] に列 [definition] (「名前 型 ...」) を足す。同じ名前の列がすでにあれば何もしない
  Future<void> _addColumnIfMissing(String table, String definition) async {
    final name = definition.split(' ').first;
    final columns = await customSelect('PRAGMA table_info($table)').get();
    if (columns.any((column) => column.read<String>('name') == name)) {
      return;
    }
    await customStatement('ALTER TABLE $table ADD COLUMN $definition');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    // 列を足すときは、すでにあれば飛ばす。移行の途中でアプリが落ちたときや、古いアプリで
    // 開き直して版だけが戻ったとき (列は残る) に、同じ列を足して開けなくならないように
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await _addColumnIfMissing(
          'mission_histories',
          "mode TEXT NOT NULL DEFAULT 'random'",
        );
        await _addColumnIfMissing('mission_histories', 'destination_lat REAL');
        await _addColumnIfMissing('mission_histories', 'destination_lng REAL');
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
      if (from < 3) {
        await _addColumnIfMissing('history_spots', 'name TEXT');
        await _addColumnIfMissing('history_spots', 'genre TEXT');
        await _addColumnIfMissing('history_spots', 'google_maps_url TEXT');
        await _addColumnIfMissing('history_spots', 'reference_heading REAL');
        await _addColumnIfMissing('history_spots', 'judge_rank TEXT');
        await _addColumnIfMissing(
          'history_spots',
          'distance_error_meters REAL',
        );
        await _addColumnIfMissing(
          'history_spots',
          'heading_error_degrees REAL',
        );
        await _addColumnIfMissing('history_spots', 'guess_lat REAL');
        await _addColumnIfMissing('history_spots', 'guess_lng REAL');
        await _addColumnIfMissing('history_spots', 'captured_heading REAL');
      }
      if (from < 4) {
        for (final column in [
          'room_code TEXT',
          'coop_sync_state TEXT',
          'coop_is_host INTEGER',
          'coop_members TEXT',
          'coop_expires_at INTEGER',
          'coop_delete_at INTEGER',
        ]) {
          await _addColumnIfMissing('mission_histories', column);
        }
        for (final column in [
          'spot_id TEXT',
          'discoverer_uid TEXT',
          'discoverer_nickname TEXT',
          'discoverer_thumb_path TEXT',
          'is_cleared INTEGER NOT NULL DEFAULT 1',
        ]) {
          await _addColumnIfMissing('history_spots', column);
        }
      }
      if (from < 5) {
        for (final column in [
          'discoverer_judge_rank TEXT',
          'discoverer_distance_error_meters REAL',
          'discoverer_heading_error_degrees REAL',
          'discoverer_guess_lat REAL',
          'discoverer_guess_lng REAL',
          'discoverer_captured_heading REAL',
        ]) {
          await _addColumnIfMissing('history_spots', column);
        }
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
