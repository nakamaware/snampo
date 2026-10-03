import 'package:snampo/core/domain/coordinate.dart';

/// 現在地を取得できない理由 (直し方が違うので、案内を出し分ける)
enum LocationUnavailableReason {
  /// 端末の位置情報がオフ
  serviceDisabled,

  /// アプリに位置情報の権限がない
  permissionDenied,
}

/// 現在地を取得できない (端末の位置情報がオフ、または権限がない)
class LocationUnavailableException implements Exception {
  /// [LocationUnavailableException] を作成する
  const LocationUnavailableException(this.reason, [this.message]);

  /// 取得できない理由
  final LocationUnavailableReason reason;

  /// 詳細
  final String? message;

  @override
  String toString() => 'LocationUnavailableException(${reason.name}, $message)';
}

/// 位置情報サービスのインターフェース
///
/// DIパターンでインターフェースとして使用し、テスト時にモックに差し替えやすくする。
/// 依存関係の逆転原則（DIP）に従い、アプリケーション層がデータ層の実装に依存しないようにする。
abstract class ILocationService {
  /// 現在位置を取得する
  ///
  /// 高精度で現在位置を取得します。
  /// 端末の位置情報がオフ、または権限がなければ [LocationUnavailableException] を投げる。
  Future<Coordinate> getCurrentPosition();

  /// [reason] を直すための設定画面を開く
  ///
  /// 位置情報がオフなら端末の位置情報の設定、権限がなければアプリの設定を開く。
  Future<void> openSettings(LocationUnavailableReason reason);
}
