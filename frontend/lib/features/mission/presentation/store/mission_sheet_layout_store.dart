import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mission_sheet_layout_store.g.dart';

/// Mission 画面のシートで、スポットをどう並べるか
enum MissionSheetLayout {
  /// 1 スポットずつ大きなカードで、横にめくる
  carousel,

  /// 全スポットを縦のリストで一覧する
  list,
}

/// Mission 画面のシートの並べ方 (アプリを閉じるまで覚えておく)
@Riverpod(keepAlive: true)
class MissionSheetLayoutStore extends _$MissionSheetLayoutStore {
  @override
  MissionSheetLayout build() => MissionSheetLayout.carousel;

  /// 並べ方を変える
  // ignore: use_setters_to_change_properties
  void change(MissionSheetLayout layout) => state = layout;
}
