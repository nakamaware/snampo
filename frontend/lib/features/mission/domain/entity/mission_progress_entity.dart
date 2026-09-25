import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/core/domain/room_code.dart';

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

    /// 撮影したときのズームの倍率 (判定は、位置誤差をこの倍率で割って決める。古いデータでは null)
    double? zoomLevel,

    /// 達成した日時 (協力プレイでは発見された日時)
    DateTime? achievedAt,

    /// 協力プレイの発見者の uid (他の人のクリアは「発見者情報つき・自分の写真なし」で反映する)
    String? discovererUid,

    /// 協力プレイの発見者のニックネーム (発見時点)
    String? discovererNickname,

    /// 協力プレイの発見者のサムネのパス (取得できていなければ null)
    String? discovererThumbPath,

    /// 協力プレイの発見者の採点 (共有されていなければ null)
    @JsonKey(fromJson: _judgementFromJson, toJson: _judgementToJson)
    PhotoJudgement? discovererJudgement,
  }) = _CheckpointProgress;

  const CheckpointProgress._();

  /// JSON から [CheckpointProgress] を生成する
  factory CheckpointProgress.fromJson(Map<String, dynamic> json) =>
      _$CheckpointProgressFromJson(json);

  /// [source] の協力プレイの発見者の情報 (発見者の 4 項目と発見日時) を引き継いだ進捗
  ///
  /// [source] に発見者がいなければ、そのまま返す。発見者の項目を 1 か所で扱い、
  /// 自分の撮影の記録と入れ替えるときに一部 (採点など) を落とさないようにする。
  CheckpointProgress withDiscovererOf(CheckpointProgress? source) {
    if (source?.discovererUid == null) {
      return this;
    }
    return copyWith(
      achievedAt: source!.achievedAt ?? achievedAt,
      discovererUid: source.discovererUid,
      discovererNickname: source.discovererNickname,
      discovererThumbPath: source.discovererThumbPath,
      discovererJudgement: source.discovererJudgement,
    );
  }

  /// 自分の撮影の採点 (採点していなければ null)
  PhotoJudgement? get judgement {
    final rank = judgeRank;
    final distance = distanceErrorMeters;
    if (rank == null || distance == null) {
      return null;
    }
    return PhotoJudgement(
      rank: rank,
      distanceErrorMeters: distance,
      headingErrorDegrees: headingErrorDegrees,
      guessPosition: guessPosition,
      capturedHeading: capturedHeading,
      zoomLevel: zoomLevel,
    );
  }
}

PhotoJudgement? _judgementFromJson(Map<String, dynamic>? json) =>
    json == null ? null : PhotoJudgement.fromJson(json);

Map<String, dynamic>? _judgementToJson(PhotoJudgement? judgement) =>
    judgement?.toJson();

/// 協力プレイで、あるスポットを発見した人
typedef CoopDiscovery =
    ({
      String uid,
      String nickname,
      DateTime clearedAt,

      /// 端末に保存した発見者のサムネのパス (取得できていなければ null)
      String? thumbPath,

      /// 発見者の採点 (共有されていなければ null)
      PhotoJudgement? judgement,
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
            : const CheckpointProgress().withDiscovererOf(current);
    return copyWith(checkpoints: updated);
  }

  /// [index] に撮影の記録 [capture] を入れた進捗を返す
  ///
  /// 協力プレイで既に発見者がいれば、発見者の情報 (採点を含む) と発見日時は残す。
  /// [index] が範囲外なら何も変えない。
  MissionProgressEntity withCapture(int index, CheckpointProgress capture) {
    if (index < 0 || index >= checkpoints.length) {
      return this;
    }
    final updated = List<CheckpointProgress?>.from(checkpoints);
    updated[index] = capture.withDiscovererOf(checkpoints[index]);
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
        discovererJudgement: d.judgement,
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
