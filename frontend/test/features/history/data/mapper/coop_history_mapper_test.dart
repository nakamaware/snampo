import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/history/data/database/history_database.dart';
import 'package:snampo/features/history/data/mapper/history_mapper.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';

void main() {
  final startedAt = DateTime.utc(2026, 9, 23, 10);
  final expiresAt = startedAt.add(const Duration(hours: 12));
  final deleteAt = startedAt.add(const Duration(days: 7));

  MissionHistoryRow coopRow({int? radiusMeters, double? lat, double? lng}) =>
      MissionHistoryRow(
        id: 'history-id',
        completedAt: startedAt.millisecondsSinceEpoch,
        startedAt: startedAt.millisecondsSinceEpoch,
        departureLat: 35,
        departureLng: 139,
        overviewPolyline: 'polyline',
        radiusMeters: radiusMeters,
        mode: historyModeCoop,
        destinationLat: lat,
        destinationLng: lng,
        roomCode: 'ABCD23',
        coopSyncState: 'inProgress',
        coopIsHost: 1,
        coopMembers: jsonEncode([
          {'uid': 'host', 'nickname': 'たろう'},
          {'uid': 'guest', 'nickname': 'はなこ'},
        ]),
        coopExpiresAt: expiresAt.millisecondsSinceEpoch,
        coopDeleteAt: deleteAt.millisecondsSinceEpoch,
      );

  const spotRows = [
    HistorySpotRow(
      id: 1,
      historyId: 'history-id',
      sortOrder: 0,
      isDestination: 0,
      lat: 35,
      lng: 139,
      streetViewImagePath: '/tmp/sv0.jpg',
      spotId: 'place-0',
      discovererUid: 'guest',
      discovererNickname: 'はなこ',
      discovererThumbPath: '/tmp/thumb0.jpg',
      isCleared: 1,
    ),
    HistorySpotRow(
      id: 2,
      historyId: 'history-id',
      sortOrder: 1,
      isDestination: 1,
      lat: 35.1,
      lng: 139.1,
      streetViewImagePath: '/tmp/sv1.jpg',
      spotId: 'place-1',
      isCleared: 0,
    ),
  ];

  group('missionHistoryFromDriftRows (coop)', () {
    test('協力プレイの情報とメンバー一覧を復元する', () {
      final history = missionHistoryFromDriftRows(
        coopRow(radiusMeters: 1000),
        spotRows,
      );

      expect(
        history.coop,
        CoopHistoryInfo(
          roomCode: 'ABCD23',
          syncState: CoopSyncState.inProgress,
          isHost: true,
          members: const [
            CoopHistoryMember(uid: 'host', nickname: 'たろう'),
            CoopHistoryMember(uid: 'guest', nickname: 'はなこ'),
          ],
          expiresAt: expiresAt,
          deleteAt: deleteAt,
        ),
      );
      expect(history.settings, isA<MissionSettingsRandom>());
    });

    test('目的地指定の協力プレイは目的地の座標から設定を復元する', () {
      final history = missionHistoryFromDriftRows(
        coopRow(lat: 35.5, lng: 139.5),
        spotRows,
      );

      expect(
        (history.settings as MissionSettingsDestination).destination.latitude,
        35.5,
      );
    });

    test('スポットごとの発見者とクリア済みかを復元する', () {
      final history = missionHistoryFromDriftRows(
        coopRow(radiusMeters: 1000),
        spotRows,
      );

      final first = history.spots[0];
      expect(first.spotId, 'place-0');
      expect(first.discovererUid, 'guest');
      expect(first.discovererNickname, 'はなこ');
      expect(first.discovererThumbPath, '/tmp/thumb0.jpg');
      expect(first.isCleared, isTrue);
      expect(history.spots[1].isCleared, isFalse);
    });

    test('ソロの履歴には協力プレイの情報がない', () {
      final history = missionHistoryFromDriftRows(
        const MissionHistoryRow(
          id: 'solo',
          completedAt: 0,
          startedAt: 0,
          departureLat: 35,
          departureLng: 139,
          overviewPolyline: 'p',
          radiusMeters: 1000,
          mode: historyModeRandom,
        ),
        const [
          HistorySpotRow(
            id: 1,
            historyId: 'solo',
            sortOrder: 0,
            isDestination: 1,
            lat: 35,
            lng: 139,
            streetViewImagePath: '/tmp/sv.jpg',
            isCleared: 1,
          ),
        ],
      );

      expect(history.coop, isNull);
    });
  });

  group('HistoryFromMissionMapper (coop)', () {
    final mission = MissionEntity(
      departure: Coordinate(latitude: 35, longitude: 139),
      destination: ImageCoordinate(
        coordinate: Coordinate(latitude: 35.1, longitude: 139.1),
        imageBase64: '',
        spotId: 'place-1',
      ),
      overviewPolyline: 'polyline',
    );

    test('協力プレイの履歴は進行中として作成する', () {
      final companion = HistoryFromMissionMapper.coopHistoryRowCompanion(
        id: 'history-id',
        mission: mission,
        startedAt: startedAt,
        coop: CoopHistoryInfo(
          roomCode: 'ABCD23',
          syncState: CoopSyncState.inProgress,
          isHost: false,
          members: const [CoopHistoryMember(uid: 'host', nickname: 'たろう')],
          expiresAt: expiresAt,
          deleteAt: deleteAt,
        ),
      );

      expect(companion.mode.value, historyModeCoop);
      expect(companion.roomCode.value, 'ABCD23');
      expect(companion.coopSyncState.value, 'inProgress');
      expect(companion.coopIsHost.value, 0);
      expect(jsonDecode(companion.coopMembers.value!), [
        {'uid': 'host', 'nickname': 'たろう'},
      ]);
      expect(companion.destinationLat.value, 35.1);
    });

    test('スポットの行にスポット ID を保存し、未クリアで作成する', () {
      final companion = HistoryFromMissionMapper.spotRowCompanion(
        historyId: 'history-id',
        sortOrder: 0,
        isLastSpot: true,
        spot: mission.destination,
        streetViewImagePath: '/tmp/sv.jpg',
        isCleared: false,
      );

      expect(companion.spotId.value, 'place-1');
      expect(companion.isCleared.value, 0);
    });
  });
}
