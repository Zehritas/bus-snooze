import 'dart:async';
// import 'dart:js_util';

import 'package:alarm/alarm.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:bus_snooze/loading_screen.dart';
import 'location_manager.dart';
import 'markers_data.dart';
import 'package:geolocator/geolocator.dart';
import 'search_delegate.dart';
// import 'destination_screen.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
// import 'station_popup.dart';

Future<void> main() async {
  runApp(const MyApp());
  await Alarm.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variables of the class
  late Timer _timer;
  LatLng? destinationLatLng;
  bool destinationSet = false;
  List<BusMarker> busMarkers = []; // Store the loaded markers
  List<String> busStationNames = [];
  final MapController mapController = MapController();
  LocationManager locationManager = LocationManager.instance;
  // MarkerData markerData = MarkerData(context);

  @override
  void initState() {
    print("Current Position1: ${locationManager.currentPosition}");

    super.initState();
    loadMarkers().then((markers) {
      busMarkers = markers;
      busStationNames = loadBusStationNames(markers);
      _timer = Timer.periodic(Duration(seconds: 5), (timer) {
        locationManager.updateLocation();
      });

      setState(() {
        locationManager.updateLocation();
      });
      print("Current Position2: ${locationManager.currentPosition}");
    });
  }

  @override
  void dispose() {
    locationManager.positionStreamController.close();
    locationManager.locationSubscription.cancel();
    super.dispose();
  }

  void updateDestination(double latitude, double longitude) {
    setState(() {
      destinationLatLng = LatLng(latitude, longitude);
      destinationSet = true;
      print('$latitude, $longitude');
    });
  }

  List<String> loadBusStationNames(List<BusMarker> markers) {
    List<String> stationNames = [];
    for (BusMarker marker in markers) {
      String name = marker.name;
      stationNames.add(name); // Add the name to the list
    }
    return stationNames;
  }

  LatLng getStationPosition(String stationName) {
    LatLng center = LatLng(54.73162694791582, 25.261266490392618);
    for (BusMarker marker in busMarkers) {
      if (marker.name == stationName) {
        return marker.point;
      }
    }
    return center;
  }

  Future<List<BusMarker>> loadMarkers() async {
    const String fileName =
        'assets/stops.csv'; // Adjust the file name/path accordingly
    MarkerData markerData =
        MarkerData(context); // Create an instance of MarkerData
    List<BusMarker> busMarkers =
        await markerData.generateMarkers(fileName, updateDestination);
    return busMarkers;
  }

  /// MAIN BUILD HERER
  @override
  Widget build(BuildContext context) {
    print("Current Position: ${locationManager.currentPosition}");
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    if (locationManager.currentPosition == null) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          locationManager.updateLocation();
        });
      });
      return ModernLoadingScreen(); // Or any other loading indicator/widget
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Bus Snooze'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.pink,
              ),
              onPressed: () async {
                final result = await showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(busStationNames));
                if (result != '') {
                  LatLng center = getStationPosition(result!);
                  mapController.move(center, 17);
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.gps_fixed_rounded,
                color: Colors.purple,
              ),
              onPressed: () {
                LatLng center = LatLng(
                    locationManager.currentPosition!.latitude,
                    locationManager.currentPosition!.longitude);
                mapController.move(center, 16);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  // onTap: (_, __) => _popupLayerController.hideAllPopups(),
                  center: LatLng(
                      locationManager.currentPosition?.latitude ?? 55.1735998,
                      locationManager.currentPosition?.longitude ?? 23.8948016),
                  zoom: 16,
                  maxZoom: 18,
                ),
                children: <Widget>[
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  CurrentLocationLayer(
                    positionStream:
                        locationManager.positionStreamController.stream,
                    style: const LocationMarkerStyle(
                        showHeadingSector: false,
                        markerSize: Size(20, 20),
                        marker: DefaultLocationMarker(
                          color: Colors.red,
                          child: Center(
                              child: Icon(Icons.accessible_forward,
                                  size: 15, color: Colors.black)),
                        )),
                  ),
                  MarkerLayer(
                    markers: busMarkers,
                  ),
                  // MarkerClusterLayerWidget(
                  //   options: MarkerClusterLayerOptions(
                  //     // animationsOptions: a,
                  //     maxClusterRadius: 100,
                  //     size: const Size(40, 40),
                  //     anchor: AnchorPos.align(AnchorAlign.center),
                  //     fitBoundsOptions: const FitBoundsOptions(
                  //       padding: EdgeInsets.all(50),
                  //       maxZoom: 15,
                  //     ),
                  //     markers: busMarkers,
                  //     builder: (context, markers) {
                  //       return Container(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(20),
                  //             color: Colors.blue),
                  //         child: Center(
                  //           child: Text(
                  //             markers.length.toString(),
                  //             style: const TextStyle(color: Colors.white),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  // SuperclusterLayer.immutable(
                  //   indexBuilder: IndexBuilders.computeWithOriginalMarkers,
                  //   initialMarkers: busMarkers,
                  //   // clusterWidgetSize: const Size(30, 30),
                  //   builder:
                  //       (context, position, markerCount, extraClusterData) {
                  //     return Container(
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(20.0),
                  //         color: Colors.purple,
                  //       ),
                  //       child: Center(
                  //         child: Text(
                  //           markerCount.toString(),
                  //           style: const TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 10,
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    locationManager.updateLocation();
                    // print('${LocationManager.currentPosition}');
                  },
                  child: const Icon(Icons.replay_outlined),
                ),
                SizedBox(
                  width: 30,
                ),
                ElevatedButton(
                  onPressed: () async {},
                  child: const Icon(Icons.find_replace_outlined),
                )
              ],
            ),

            // Other widgets can be added below the map
          ],
        ),
      );
    }
  }
}
