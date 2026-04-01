// 旧バージョンが端末に残していた MissionHistoryEntity 形式の JSON 等は読み込まない
// (公開前のため破棄してよい前提。ソースは履歴 Drift のみ)
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:snampo/core/storage/photo_storage.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/data/database/history_database.dart';
import 'package:snampo/features/history/data/mapper/history_mapper.dart';
import 'package:snampo/features/history/data/streetview_storage.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// Drift 上の履歴 CRUD
class HistoryRepository implements IHistoryRepository {
  /// [HistoryRepository] を作成する
  HistoryRepository(this._db, this._streetViewStorage, this._photoStorage);

  final HistoryDatabase _db;
  final StreetViewStorage _streetViewStorage;
  final IPhotoStorage _photoStorage;

  /// 新しい履歴を保存する (Street View はファイル化してパスのみ DB に保持)
  @override
  Future<void> insertHistory({
    required String id,
    required MissionEntity mission,
    required MissionProgressEntity progress,
  }) async {
    final spots = HistoryFromMissionMapper.orderedSpots(mission);
    final now = DateTime.now();
    final createdPaths = <String>[];

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
          createdPaths.add(path);
          final cp = i < cps.length ? cps[i] : null;
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
                ),
              );
        }
      });
    } catch (error, stackTrace) {
      for (final path in createdPaths) {
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
    final userPhotoPaths =
        await (_db.selectOnly(spots)
              ..addColumns([spots.userPhotoPath])
              ..where(
                spots.historyId.equals(id) & spots.userPhotoPath.isNotNull(),
              ))
            .map((row) => row.read(spots.userPhotoPath)!)
            .get();

    await _db.transaction(() async {
      await (_db.delete(_db.missionHistories)
        ..where((t) => t.id.equals(id))).go();
    });

    for (final path in userPhotoPaths) {
      try {
        await _photoStorage.deletePhoto(path);
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
    final rows = await q.get();
    final out = <MissionHistory>[];
    for (final h in rows) {
      out.add(await _rowToMissionHistory(h));
    }
    return out;
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

  Future<MissionHistory> _rowToMissionHistory(MissionHistoryRow h) async {
    final spotRows =
        await (_db.select(_db.historySpots)
              ..where((t) => t.historyId.equals(h.id))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return missionHistoryFromDriftRows(h, spotRows);
  }
}
