import 'package:snampo/features/coop/application/usecase/retry_pending_clears_use_case.dart';

/// 送り直しても共有できなかった発見を、ユーザー向けの文言にする
String pendingClearFailureMessage(PendingClearFailure failure) {
  final room = failure.task.roomCode;
  return switch (failure.reason) {
    PendingClearFailureReason.alreadyCleared =>
      // 日本語の文なので、分けた文字列の間に空白は入れない
      // ignore: missing_whitespace_between_adjacent_strings
      'ルーム $room で、先に${failure.existing?.nickname ?? 'ほかの人'}さんが発見していたため、'
          'あなたの発見を共有できませんでした',
    PendingClearFailureReason.roomClosed =>
      'ルーム $room が終了していたため、あなたの発見を共有できませんでした',
  };
}
