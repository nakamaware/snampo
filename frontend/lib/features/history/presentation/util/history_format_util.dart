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

/// スポット行一覧から最初のユーザー写真パスを返す
String? firstUserPhotoPath(List<MissionHistorySpot> spots) {
  for (final line in spots) {
    final p = line.userPhotoPath;
    if (p != null && p.isNotEmpty) {
      return p;
    }
  }
  return null;
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
