// 旧バージョンが端末に残していた MissionHistoryEntity 形式の JSON 等は読み込まない
// (公開前のため破棄してよい前提。ソースは履歴 Drift のみ)
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/data/database/history_database.dart';
import 'package:snampo/features/history/data/history_photo_storage.dart';
import 'package:snampo/features/history/data/mapper/history_mapper.dart';
import 'package:snampo/features/history/data/streetview_storage.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/photo_judgement.dart';
import 'package:uuid/uuid.dart';

/// Drift 上の履歴 CRUD
class HistoryRepository implements IHistoryRepository {
  /// [HistoryRepository] を作成する
  HistoryRepository(
    this._db,
    this._streetViewStorage,
    this._historyPhotoStorage, [
    Uuid? uuid,
  ]) : _uuid = uuid ?? const Uuid();

  final HistoryDatabase _db;
  final Uuid _uuid;
  final StreetViewStorage _streetViewStorage;
  final HistoryPhotoStorage _historyPhotoStorage;

  /// 新しい履歴を保存する (Street View・ユーザー写真はファイル化してパスのみ DB に保持)
  @override
  Future<void> insertHistory({
    required String id,
    required MissionEntity mission,
    required MissionProgressEntity progress,
  }) async {
    final spots = HistoryFromMissionMapper.orderedSpots(mission);
    final now = DateTime.now();
    final createdStreetViewPaths = <String>[];
    final createdUserPhotoPaths = <String>[];

    try {
      await _db.transaction(() async {
        await _db
            .into(_db.missionHistories)
            .insert(
              HistoryFromMissionMapper.missionHistoryRowCompanion(
                id: id,
                mission: mission,
                completedAt: now,
                startedAt: progress.startedAt,
              ),
            );

        final cps = progress.checkpoints;
        for (var i = 0; i < spots.length; i++) {
          final spot = spots[i];
          final path = await _streetViewStorage.saveBase64Image(
            historyId: id,
            sortOrder: i,
            imageBase64: spot.imageBase64,
          );
          createdStreetViewPaths.add(path);
          final cp = i < cps.length ? cps[i] : null;
          String? userPhotoPath;
          final sourcePhotoPath = cp?.userPhotoPath;
          if (sourcePhotoPath != null) {
            userPhotoPath = await _historyPhotoStorage.copyUserPhoto(
              historyId: id,
              sortOrder: i,
              sourcePath: sourcePhotoPath,
            );
            if (userPhotoPath != null) {
              createdUserPhotoPaths.add(userPhotoPath);
            }
          }
          await _db
              .into(_db.historySpots)
              .insert(
                HistoryFromMissionMapper.spotRowCompanion(
                  historyId: id,
                  sortOrder: i,
                  isLastSpot: i == spots.length - 1,
                  spot: spot,
                  streetViewImagePath: path,
                  checkpointProgress: cp,
                  userPhotoPath: userPhotoPath,
                ),
              );
        }
      });
    } catch (error, stackTrace) {
      for (final path in createdStreetViewPaths) {
        try {
          await _streetViewStorage.delete(path);
        } catch (cleanupError, cleanupStackTrace) {
          log(
            'insertHistory: failed to cleanup Street View file: $path',
            error: cleanupError,
            stackTrace: cleanupStackTrace,
            name: 'HistoryRepository',
          );
        }
      }
      for (final path in createdUserPhotoPaths) {
        try {
          await _historyPhotoStorage.delete(path);
        } catch (cleanupError, cleanupStackTrace) {
          log(
            'insertHistory: failed to cleanup user photo file: $path',
            error: cleanupError,
            stackTrace: cleanupStackTrace,
            name: 'HistoryRepository',
          );
        }
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// 履歴と紐づくファイルを削除する
  ///
  /// スポット行から [HistorySpotRow.userPhotoPath] を SELECT で集めたうえで、
  /// トランザクション内で親行を削除する (cascade でスポット行も削除)。
  /// DB コミット後にユーザー写真・Street View ファイルをベストエフォートで削除する。
  @override
  Future<void> deleteHistory(String id) async {
    final spots = _db.historySpots;
    final userPhotoPaths = await (_db.selectOnly(spots)
          ..addColumns([spots.userPhotoPath, spots.discovererThumbPath])
          ..where(spots.historyId.equals(id)))
        .map(
          (row) =>
              [
                row.read(spots.userPhotoPath),
                row.read(spots.discovererThumbPath),
              ].nonNulls,
        )
        .get()
        .then((rows) => rows.expand((paths) => paths).toList());

    await _db.transaction(() async {
      await (_db.delete(_db.missionHistories)
        ..where((t) => t.id.equals(id))).go();
    });

    for (final path in userPhotoPaths) {
      try {
        await _historyPhotoStorage.delete(path);
      } catch (e, st) {
        log(
          'deleteHistory: failed to delete user photo: $path',
          error: e,
          stackTrace: st,
          name: 'HistoryRepository',
        );
      }
    }

    try {
      await _streetViewStorage.deleteForHistory(id);
    } catch (e, st) {
      log(
        'deleteHistory: failed to delete Street View files for history: $id',
        error: e,
        stackTrace: st,
        name: 'HistoryRepository',
      );
    }
  }

  /// 履歴一覧 (完了日時の新しい順)
  @override
  Future<List<MissionHistory>> getHistories({
    int? limit,
    int offset = 0,
  }) async {
    final q = _db.select(_db.missionHistories)
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    if (limit != null) {
      q.limit(limit, offset: offset);
    }
    return _toMissionHistories(await q.get());
  }

  /// 履歴行のスポットを一括で取得して [MissionHistory] にする (行の順序を保つ)
  Future<List<MissionHistory>> _toMissionHistories(
    List<MissionHistoryRow> rows,
  ) async {
    if (rows.isEmpty) {
      return [];
    }
    final ids = rows.map((r) => r.id).toList();
    final allSpotRows = await _selectHistorySpotsForHistoryIds(ids);
    final spotsByHistoryId = <String, List<HistorySpotRow>>{};
    for (final s in allSpotRows) {
      (spotsByHistoryId[s.historyId] ??= <HistorySpotRow>[]).add(s);
    }
    return [
      for (final h in rows)
        missionHistoryFromDriftRows(h, spotsByHistoryId[h.id] ?? const []),
    ];
  }

  /// id で 1 件取得
  @override
  Future<MissionHistory?> getHistoryById(String id) async {
    final h =
        await (_db.select(_db.missionHistories)
          ..where((t) => t.id.equals(id))).getSingleOrNull();
    if (h == null) {
      return null;
    }
    return _rowToMissionHistory(h);
  }

  @override
  Future<void> upsertCoopHistory({
    required MissionEntity mission,
    required DateTime startedAt,
    required CoopHistoryInfo coop,
  }) async {
    final existing = await _selectCoopRow(coop.roomCode);
    if (existing != null) {
      await (_db.update(_db.missionHistories)
        ..where((t) => t.id.equals(existing.id))).write(
        MissionHistoriesCompanion(
          coopMembers: Value(coopMembersToDb(coop.members)),
        ),
      );
      return;
    }

    final id = _uuid.v4();
    final spots = HistoryFromMissionMapper.orderedSpots(mission);
    final createdStreetViewPaths = <String>[];
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.missionHistories)
            .insert(
              HistoryFromMissionMapper.coopHistoryRowCompanion(
                id: id,
                mission: mission,
                startedAt: startedAt,
                coop: coop,
              ),
            );
        for (var i = 0; i < spots.length; i++) {
          // ミッション画像は、ルームに入ってダウンロードした時点ですべてローカルに保存する
          final path = await _streetViewStorage.saveBase64Image(
            historyId: id,
            sortOrder: i,
            imageBase64: spots[i].imageBase64,
          );
          createdStreetViewPaths.add(path);
          await _db
              .into(_db.historySpots)
              .insert(
                HistoryFromMissionMapper.spotRowCompanion(
                  historyId: id,
                  sortOrder: i,
                  isLastSpot: i == spots.length - 1,
                  spot: spots[i],
                  streetViewImagePath: path,
                  isCleared: false,
                ),
              );
        }
      });
    } catch (error, stackTrace) {
      for (final path in createdStreetViewPaths) {
        try {
          await _streetViewStorage.delete(path);
        } catch (cleanupError, cleanupStackTrace) {
          log(
            'upsertCoopHistory: failed to cleanup Street View file: $path',
            error: cleanupError,
            stackTrace: cleanupStackTrace,
            name: 'HistoryRepository',
          );
        }
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<MissionHistory?> getCoopHistory(RoomCode roomCode) async {
    final row = await _selectCoopRow(roomCode);
    return row == null ? null : _rowToMissionHistory(row);
  }

  @override
  Future<void> applyCoopDiscoverer({
    required RoomCode roomCode,
    required SpotId spotId,
    required String discovererUid,
    required String discovererNickname,
    required DateTime clearedAt,
    required PhotoJudgement? judgement,
  }) async {
    final spot = await _selectCoopSpot(roomCode, spotId);
    if (spot == null) {
      return;
    }
    final discovererChanged = spot.discovererUid != discovererUid;
    await (_db.update(_db.historySpots)
      ..where((t) => t.id.equals(spot.id))).write(
      HistorySpotsCompanion(
        discovererUid: Value(discovererUid),
        discovererNickname: Value(discovererNickname),
        achievedAt: Value(clearedAt.millisecondsSinceEpoch),
        isCleared: const Value(1),
        discovererJudgeRank: Value(judgement?.rank.name),
        discovererDistanceErrorMeters: Value(judgement?.distanceErrorMeters),
        discovererHeadingErrorDegrees: Value(judgement?.headingErrorDegrees),
        discovererGuessLat: Value(judgement?.guessPosition?.latitude),
        discovererGuessLng: Value(judgement?.guessPosition?.longitude),
        discovererCapturedHeading: Value(judgement?.capturedHeading),
        discovererZoomLevel: Value(judgement?.zoomLevel),
        // 発見者が変わった場合 (自分の送信待ちのクリアが拒否されたなど) は前のサムネを外す
        discovererThumbPath:
            discovererChanged ? const Value(null) : const Value.absent(),
      ),
    );
    final oldThumb = spot.discovererThumbPath;
    if (discovererChanged && oldThumb != null) {
      await _historyPhotoStorage.delete(oldThumb);
    }
  }

  @override
  Future<void> saveCoopThumb({
    required RoomCode roomCode,
    required SpotId spotId,
    required String sourcePath,
  }) async {
    final spot = await _selectCoopSpot(roomCode, spotId);
    if (spot == null) {
      return;
    }
    final path = await _historyPhotoStorage.copyCoopThumb(
      historyId: spot.historyId,
      sortOrder: spot.sortOrder,
      sourcePath: sourcePath,
    );
    if (path == null) {
      return;
    }
    await (_db.update(_db.historySpots)..where(
      (t) => t.id.equals(spot.id),
    )).write(HistorySpotsCompanion(discovererThumbPath: Value(path)));
    final oldThumb = spot.discovererThumbPath;
    if (oldThumb != null && oldThumb != path) {
      await _historyPhotoStorage.delete(oldThumb);
    }
  }

  @override
  Future<void> saveCoopUserPhoto({
    required RoomCode roomCode,
    required SpotId spotId,
    required CheckpointProgress checkpoint,
  }) async {
    final spot = await _selectCoopSpot(roomCode, spotId);
    final source = checkpoint.userPhotoPath;
    if (spot == null || source == null) {
      return;
    }
    final path = await _historyPhotoStorage.copyUserPhoto(
      historyId: spot.historyId,
      sortOrder: spot.sortOrder,
      sourcePath: source,
    );
    await (_db.update(_db.historySpots)
      ..where((t) => t.id.equals(spot.id))).write(
      HistorySpotsCompanion(
        userPhotoPath: Value(path),
        judgeRank: Value(checkpoint.judgeRank?.name),
        distanceErrorMeters: Value(checkpoint.distanceErrorMeters),
        headingErrorDegrees: Value(checkpoint.headingErrorDegrees),
        guessLat: Value(checkpoint.guessPosition?.latitude),
        guessLng: Value(checkpoint.guessPosition?.longitude),
        capturedHeading: Value(checkpoint.capturedHeading),
        zoomLevel: Value(checkpoint.zoomLevel),
      ),
    );
  }

  @override
  Future<void> finalizeCoopHistory(
    RoomCode roomCode, {
    required DateTime completedAt,
  }) async {
    await (_db.update(_db.missionHistories)
      ..where((t) => t.roomCode.equals(roomCode.value))).write(
      MissionHistoriesCompanion(
        coopSyncState: Value(CoopSyncState.finalized.name),
        completedAt: Value(completedAt.millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<List<MissionHistory>> getInProgressCoopHistories() async {
    final rows =
        await (_db.select(_db.missionHistories)..where(
          (t) =>
              t.mode.equals(historyModeCoop) &
              t.coopSyncState.equals(CoopSyncState.inProgress.name),
        )).get();
    return _toMissionHistories(rows);
  }

  Future<MissionHistoryRow?> _selectCoopRow(RoomCode roomCode) =>
      (_db.select(_db.missionHistories)
            ..where((t) => t.roomCode.equals(roomCode.value))
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<HistorySpotRow?> _selectCoopSpot(
    RoomCode roomCode,
    SpotId spotId,
  ) async {
    final history = await _selectCoopRow(roomCode);
    if (history == null) {
      return null;
    }
    return (_db.select(_db.historySpots)..where(
      (t) => t.historyId.equals(history.id) & t.spotId.equals(spotId.value),
    )).getSingleOrNull();
  }

  Future<MissionHistory> _rowToMissionHistory(MissionHistoryRow h) async {
    final spotRows = await _selectHistorySpotsForSingleHistoryId(h.id);
    return missionHistoryFromDriftRows(h, spotRows);
  }

  /// 単一履歴用 (詳細 1 件取得)。一覧と異なり 1 回の spots 取得で足りる。
  Future<List<HistorySpotRow>> _selectHistorySpotsForSingleHistoryId(
    String historyId,
  ) async {
    return (_db.select(_db.historySpots)
          ..where((t) => t.historyId.equals(historyId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// 複数履歴分の `history_spots` を一括取得する (SQLite 変数数の制限のため id を分割)。
  Future<List<HistorySpotRow>> _selectHistorySpotsForHistoryIds(
    List<String> historyIds,
  ) async {
    if (historyIds.isEmpty) {
      return [];
    }
    const chunkSize = 500;
    final out = <HistorySpotRow>[];
    for (var i = 0; i < historyIds.length; i += chunkSize) {
      final end =
          (i + chunkSize > historyIds.length)
              ? historyIds.length
              : i + chunkSize;
      final chunk = historyIds.sublist(i, end);
      final part =
          await (_db.select(_db.historySpots)
                ..where((t) => t.historyId.isIn(chunk))
                ..orderBy([
                  (t) => OrderingTerm.asc(t.historyId),
                  (t) => OrderingTerm.asc(t.sortOrder),
                ]))
              .get();
      out.addAll(part);
    }
    return out;
  }
}
