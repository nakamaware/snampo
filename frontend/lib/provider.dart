import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/location_model.dart';

final targetProvider = StateProvider<LocationPoint?>((ref) => null);
final routeProvider = StateProvider<String?>((ref) => null);
final midpointInfoListProvider = StateProvider<List<MidPoint>?>((ref) => null);
