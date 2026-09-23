import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';

/// [start] から [end] までの経過時間を日本語の表記にする
String formatMissionDuration(DateTime start, DateTime end) {
  final d = end.difference(start);
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  if (hours > 0) {
    return '$hours時間$minutes分$seconds秒';
  }
  if (minutes > 0) {
    return '$minutes分$seconds秒';
  }
  return '$seconds秒';
}

/// [dateTime] を `yyyy/MM/dd HH:mm` 形式にフォーマットする
String formatCompletedDate(DateTime dateTime) {
  final y = dateTime.year;
  final mo = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  final h = dateTime.hour.toString().padLeft(2, '0');
  final mi = dateTime.minute.toString().padLeft(2, '0');
  return '$y/$mo/$d $h:$mi';
}

/// [MissionSettings] を日本語ラベルに変換する
String formatMissionSettings(MissionSettings settings) {
  return settings.when(
    random: (r) => 'ミッション設定: ランダム (半径 ${r.meters} m)',
    destination:
        (c) =>
            'ミッション設定: 目的地指定 '
            '(${c.latitude.toStringAsFixed(5)}, '
            '${c.longitude.toStringAsFixed(5)})',
  );
}

/// 履歴の一覧に表示する代表のサムネのパスを返す (最初のユーザー写真)
///
/// 自分の写真がなければ、協力プレイの発見者のサムネを使う。
String? historyThumbnailPath(List<MissionHistorySpot> spots) {
  for (final line in spots) {
    final p = line.userPhotoPath;
    if (p != null && p.isNotEmpty) {
      return p;
    }
  }
  for (final line in spots) {
    final p = line.discovererThumbPath;
    if (p != null && p.isNotEmpty) {
      return p;
    }
  }
  return null;
}

/// 協力プレイの履歴のラベル
String formatCoopLabel(CoopHistoryInfo coop) =>
    coop.syncState == CoopSyncState.inProgress ? 'みんなで (進行中)' : 'みんなで';

/// 協力プレイのメンバー一覧 (重複した名前には番号を付ける)
String formatCoopMembers(CoopHistoryInfo coop) {
  final names = displayNicknames([
    for (final m in coop.members) (uid: m.uid, nickname: m.nickname),
  ]);
  return 'メンバー: ${coop.members.map((m) => names[m.uid]).join('、')}';
}

/// 位置誤差 (m) を表示用にフォーマットする
String formatDistanceError(double? meters) {
  if (meters == null) {
    return '取得できませんでした';
  }
  return '${meters.toStringAsFixed(1)} m';
}

/// 方角誤差 (度) を表示用にフォーマットする
String formatHeadingError(double? degrees) {
  if (degrees == null) {
    return '取得できませんでした';
  }
  final abs = degrees.abs();
  if (abs < 0.05) {
    return 'JUST!';
  }
  final formatted = abs.toStringAsFixed(1);
  return degrees > 0 ? '右に$formatted度' : '左に$formatted度';
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
