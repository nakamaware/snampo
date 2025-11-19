import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:snampo/snap_menu.dart';
import 'package:snampo/provider.dart';
import 'package:snampo/location_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MissionPage extends HookWidget {
  final double radius;
  const MissionPage({required this.radius, super.key});

  Future<LocationModel> makeMission() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final dio = Dio();
    String radiusString =
        (radius * 1000).toInt().toString(); // km から m にし整数値の文字列に
    final response = await dio.get(
      'http://52.197.206.202/route/',
      queryParameters: {
        'currentLat': position.latitude.toString(),
        'currentLng': position.longitude.toString(),
        'radius': radiusString,
      },
    );
    String jsonString = response.toString();
    Map<String, dynamic> jsonData = await jsonDecode(jsonString);
    LocationModel missionInfo = LocationModel.fromJson(jsonData);
    return missionInfo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textstyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // final future = useMemoized(getCurrentLocation);
    final future = useMemoized(makeMission);
    final snapshot = useFuture(future, initialData: null);

    if (snapshot.hasData && snapshot.data != null) {
      final LocationModel missionInfo = snapshot.data!;
      GlobalVariables.target = missionInfo.destination!;
      GlobalVariables.route = missionInfo.overviewPolyline!;
      GlobalVariables.midpointInfoList = missionInfo.midpoints!;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'On MISSION',
            style: textstyle,
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
        ),
        body: Stack(children: [
          MapView(currentLocation: missionInfo.departure!),
          SnapView(),
        ]),
      );
    } else if (snapshot.hasError) {
      return const Center(
        child: Text('error occurred'),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'On MISSION',
            style: textstyle,
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
        ),
        body: const Center(
          child: Column(
            children: [
              Text("NOW LOADING"),
            ],
          ),
        ),
      );
    }
  }
}

class MapView extends StatefulWidget {
  final LocationPoint currentLocation;
  const MapView({required this.currentLocation, super.key});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // マップの表示制御用
  late GoogleMapController mapController;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  String encodedPolyline = GlobalVariables.route;

  @override
  void initState() {
    super.initState();
    _decodePolyline();
  }

  void _decodePolyline() async {
    List<PointLatLng> result = PolylinePoints().decodePolyline(encodedPolyline);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId("poly"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 3,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                //マップの初期位置を指定
                zoom: 17, //ズーム
                target: LatLng(
                  //緯度, 経度
                  widget.currentLocation.latitude!,
                  widget.currentLocation.longitude!,
                ),
              ),
              markers: {
                Marker(
                  markerId: MarkerId("marker_1"),
                  position: LatLng(
                    GlobalVariables.target!.latitude!,
                    GlobalVariables.target!.longitude!,
                  ),
                )
              },
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ],
        ),
      ),
    );
  }
}
