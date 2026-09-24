import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

part 'mission_progress_entity.freezed.dart';
part 'mission_progress_entity.g.dart';

/// チェックポイントの進捗
///
/// 各チェックポイント（経由地・目的地）におけるユーザの行動記録
@freezed
abstract class CheckpointProgress with _$CheckpointProgress {
  /// [CheckpointProgress] を作成する
  const factory CheckpointProgress({
    /// 撮影時の位置
    @NullableCoordinateConverter() Coordinate? guessPosition,

    /// 保存した写真のファイルパス
    String? userPhotoPath,

    /// 撮影時の方角
    double? capturedHeading,

    /// 位置誤差 (メートル)
    double? distanceErrorMeters,

    /// 方角誤差 (度)
    double? headingErrorDegrees,

    /// 採点ランク
    @PhotoJudgeRankConverter() PhotoJudgeRank? judgeRank,

    /// 達成した日時 (協力プレイでは発見された日時)
    DateTime? achievedAt,

    /// 協力プレイの発見者の uid (他の人のクリアは「発見者情報つき・自分の写真なし」で反映する)
    String? discovererUid,

    /// 協力プレイの発見者のニックネーム (発見時点)
    String? discovererNickname,

    /// 協力プレイの発見者のサムネのパス (取得できていなければ null)
    String? discovererThumbPath,
  }) = _CheckpointProgress;

  /// JSON から [CheckpointProgress] を生成する
  factory CheckpointProgress.fromJson(Map<String, dynamic> json) =>
      _$CheckpointProgressFromJson(json);
}

/// Coordinate? の JSON 変換
///
/// nullable な [Coordinate] を JSON と相互変換する
class NullableCoordinateConverter
    implements JsonConverter<Coordinate?, Map<String, dynamic>?> {
  /// [NullableCoordinateConverter] を作成する
  const NullableCoordinateConverter();

  @override
  Coordinate? fromJson(Map<String, dynamic>? json) =>
      json == null ? null : const CoordinateConverter().fromJson(json);

  @override
  Map<String, dynamic>? toJson(Coordinate? object) =>
      object == null ? null : const CoordinateConverter().toJson(object);
}

/// PhotoJudgeRank? の JSON 変換
///
/// 旧バージョンで永続化された未知の値 `retry` は [PhotoJudgeRank.miss] として
/// 復元する (未知の enum 名で `$enumDecodeNullable` が例外を投げるのを防ぐ)。
class PhotoJudgeRankConverter
    implements JsonConverter<PhotoJudgeRank?, String?> {
  /// [PhotoJudgeRankConverter] を作成する
  const PhotoJudgeRankConverter();

  @override
  PhotoJudgeRank? fromJson(String? json) {
    if (json == null) {
      return null;
    }
    if (json == 'retry') {
      return PhotoJudgeRank.miss;
    }
    for (final rank in PhotoJudgeRank.values) {
      if (rank.name == json) {
        return rank;
      }
    }
    return null;
  }

  @override
  String? toJson(PhotoJudgeRank? object) => object?.name;
}

/// 協力プレイで、あるスポットを発見した人
typedef CoopDiscovery =
    ({
      String uid,
      String nickname,
      DateTime clearedAt,

      /// 端末に保存した発見者のサムネのパス (取得できていなければ null)
      String? thumbPath,
    });

/// ミッション進捗エンティティ
///
/// ミッション開始時刻と各チェックポイントの進捗を保持する
@freezed
abstract class MissionProgressEntity with _$MissionProgressEntity {
  /// [MissionProgressEntity] を作成する
  const factory MissionProgressEntity({
    /// ミッション開始時刻
    required DateTime startedAt,

    /// 協力プレイのルームコード (ソロでは null)
    @RoomCodeConverter() RoomCode? roomCode,

    /// 各チェックポイントの進捗（インデックス = スポット番号、null = 未挑戦）
    @Default([])
    @JsonKey(toJson: _missionProgressCheckpointsToJson)
    List<CheckpointProgress?> checkpoints,
  }) = _MissionProgressEntity;

  const MissionProgressEntity._();

  /// JSON から [MissionProgressEntity] を生成する
  factory MissionProgressEntity.fromJson(Map<String, dynamic> json) =>
      _$MissionProgressEntityFromJson(json);

  /// 協力プレイで、共有の結果がまだ付いていない撮影 (自分の写真はあるが発見者がいない) の番号
  Iterable<int> get unsharedCaptureIndexes sync* {
    for (final (index, checkpoint) in checkpoints.indexed) {
      if (checkpoint?.userPhotoPath != null &&
          checkpoint?.discovererUid == null) {
        yield index;
      }
    }
  }

  /// [index] の撮影の記録 (自分の写真と採点) を捨てた進捗を返す
  ///
  /// 協力プレイで発見を共有できなかったとき、誰もクリアしていない扱いに戻すために使う。
  /// 発見者の情報があれば、それだけを残す。写真のファイルは消さない (呼び出し側で消す)。
  /// [roomCode] がこの進捗のルームと違えば (進捗が次のルームに入れ替わったなど)、何も変えない。
  MissionProgressEntity withoutCapture(RoomCode roomCode, int index) {
    if (this.roomCode != roomCode || index < 0 || index >= checkpoints.length) {
      return this;
    }
    final current = checkpoints[index];
    final updated = List<CheckpointProgress?>.from(checkpoints);
    updated[index] =
        current?.discovererUid == null
            ? null
            : CheckpointProgress(
              achievedAt: current!.achievedAt,
              discovererUid: current.discovererUid,
              discovererNickname: current.discovererNickname,
              discovererThumbPath: current.discovererThumbPath,
            );
    return copyWith(checkpoints: updated);
  }

  /// 協力プレイの発見者を反映した進捗を返す (キーはチェックポイントのインデックス)
  ///
  /// 他の人のクリアは「発見者情報つき・自分の写真なし」として反映する。
  /// [roomCode] がこの進捗のルームと違えば (抜けた前のルームの通知など)、何も変えない。
  MissionProgressEntity withCoopDiscoveries(
    RoomCode roomCode,
    Map<int, CoopDiscovery> discoveries,
  ) {
    if (this.roomCode != roomCode) {
      return this;
    }
    final updated = List<CheckpointProgress?>.from(checkpoints);
    for (final MapEntry(key: index, value: d) in discoveries.entries) {
      if (index < 0 || index >= updated.length) continue;
      final previous = updated[index];
      updated[index] = (previous ?? const CheckpointProgress()).copyWith(
        discovererUid: d.uid,
        discovererNickname: d.nickname,
        discovererThumbPath:
            d.thumbPath ??
            (previous?.discovererUid == d.uid
                ? previous?.discovererThumbPath
                : null),
        achievedAt: d.clearedAt,
      );
    }
    final next = copyWith(checkpoints: updated);
    return next == this ? this : next;
  }
}

List<Object?> _missionProgressCheckpointsToJson(
  List<CheckpointProgress?> list,
) => list.map((e) => e?.toJson()).toList();
