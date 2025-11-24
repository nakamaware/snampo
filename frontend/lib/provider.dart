import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:snampo/location_model.dart';

// final currentLocationProvider = FutureProvider<Position>((ref) async {
//   Position position = await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );
//   return position;
// });

// final createMissionProvider = FutureProvider<String>((ref) async {
//   final dio = Dio();

//   ref.watch(currentLocationProvider).when(
//         data: data,
//         error: error,
//         loading: loading,
//       );

//   try {
//     final response = await dio.get(
//       'http://localhost:80/route',
//       queryParameters: {
//         'currentLat': '35.6895',
//         'currentLng': '139.6917',
//         'radius': '10',
//       },
//     );

//     return (response.data);
//   } catch (e) {
//     return ('Error: $e');
//   }
// });

// final targetProvider = StateProvider<Position?>((ref) => (null));
// final routeProvider = StateProvider<String?>((ref) => (null));
// final landmarkInfoProvider = StateProvider<List<String>?>((ref) => (null));
class GlobalVariables {
  static late LocationPoint target;
  static late String route;
  static late List<MidPoint> midpointInfoList;
}
