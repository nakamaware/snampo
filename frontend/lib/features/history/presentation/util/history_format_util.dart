import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

export 'package:snampo/features/mission/presentation/util/mission_format_util.dart'
    show formatMissionDuration;

/// [dateTime] を `yyyy/MM/dd HH:mm` 形式にフォーマットする
String formatCompletedDate(DateTime dateTime) {
  final y = dateTime.year;
  final mo = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  final h = dateTime.hour.toString().padLeft(2, '0');
  final mi = dateTime.minute.toString().padLeft(2, '0');
  return '$y/$mo/$d $h:$mi';
}

/// 履歴スポットの見出しを返す
String formatHistorySpotTitle({
  required MissionHistorySpot spot,
  required int index,
}) {
  if (spot.isDestination) {
    return spot.name ?? 'GOAL';
  }
  return spot.name ?? 'Spot ${index + 1}';
}

const _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

/// 一覧に出す日付 (`9月23日 (水) 14:05`)
String formatHistoryDate(DateTime dateTime) {
  final h = dateTime.hour.toString().padLeft(2, '0');
  final mi = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.month}月${dateTime.day}日 '
      '(${_weekdays[dateTime.weekday - 1]}) $h:$mi';
}

/// 一覧の月の見出し (`2026年9月`)
String formatHistoryMonth(DateTime dateTime) =>
    '${dateTime.year}年${dateTime.month}月';

/// 一覧に出す、かかった時間 (秒を省く。1 分未満なら秒)
String formatMissionDurationShort(DateTime start, DateTime end) {
  final d = end.difference(start);
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours > 0) {
    return '$hours時間$minutes分';
  }
  if (minutes > 0) {
    return '$minutes分';
  }
  return '${d.inSeconds}秒';
}

/// 履歴のスポットに出す写真と判定
///
/// 自分が撮っていれば自分のもの、撮っていなければ協力プレイの発見者のもの。
/// 未クリアのスポットには出さない。
extension HistorySpotShown on MissionHistorySpot {
  /// 出す写真のパス
  String? get shownPhotoPath =>
      isCleared ? userPhotoPath ?? discovererThumbPath : null;

  /// 出す判定
  PhotoJudgeRank? get shownRank =>
      isCleared ? judgeRank ?? discovererJudgement?.rank : null;
}
