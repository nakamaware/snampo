import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/storage/photo_storage.dart';
import 'package:snampo/core/storage/photo_storage_impl.dart';

part 'photo_storage_provider.g.dart';

/// 写真ストレージのプロバイダー
@riverpod
IPhotoStorage photoStorage(Ref ref) {
  return PhotoStorageImpl();
}
