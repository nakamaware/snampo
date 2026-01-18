import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_store.g.dart';

/// 写真のパスを保存するストア
@riverpod
class CameraStore extends _$CameraStore {
  @override
  Map<int, String> build() {
    // 初期状態は空のマップ
    return {};
  }

  /// 写真のパスを保存する
  void savePhoto(int index, String path) {
    // Mapを新しく作成して状態を更新（イミュータブルな更新）
    state = {...state, index: path};
  }

  /// 指定したインデックスの写真パスを取得する
  String? getPath(int index) => state[index];
}
