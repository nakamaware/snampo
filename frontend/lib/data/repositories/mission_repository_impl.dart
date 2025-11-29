import 'package:snampo/data/datasources/api_client.dart';
import 'package:snampo/data/models/location_dto.dart';
import 'package:snampo/domain/entities/location_entity.dart';
import 'package:snampo/domain/repositories/mission_repository.dart';

/// ミッションリポジトリの実装
class MissionRepositoryImpl implements MissionRepository {
  /// MissionRepositoryImplのコンストラクタ
  MissionRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<LocationEntity> getMission({
    required double radius,
    required double currentLat,
    required double currentLng,
  }) async {
    final radiusString =
        (radius * 1000).toInt().toString(); // km から m にし整数値の文字列に
    final dto = await _apiClient.getRoute(
      currentLat: currentLat,
      currentLng: currentLng,
      radius: radiusString,
    );
    return _toEntity(dto);
  }

  /// DTOをエンティティに変換
  LocationEntity _toEntity(LocationDto dto) {
    return LocationEntity(
      departure: dto.departure != null
          ? LocationPointEntity(
              latitude: dto.departure!.latitude,
              longitude: dto.departure!.longitude,
            )
          : null,
      destination: dto.destination != null
          ? LocationPointEntity(
              latitude: dto.destination!.latitude,
              longitude: dto.destination!.longitude,
            )
          : null,
      midpoints: dto.midpoints
              ?.map(
                (midPointDto) => MidPointEntity(
                  imageLatitude: midPointDto.imageLatitude,
                  imageLongitude: midPointDto.imageLongitude,
                  latitude: midPointDto.latitude,
                  longitude: midPointDto.longitude,
                  imageUtf8: midPointDto.imageUtf8,
                ),
              )
              .toList() ??
          [],
      overviewPolyline: dto.overviewPolyline,
    );
  }
}
