import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:csv/csv.dart';
import 'package:bus_snooze/location_manager.dart';
// import 'main.dart';
import 'destination_screen.dart';

class StopInfo {
  final String stopName;
  final double stopLat;
  final double stopLon;

  StopInfo({
    required this.stopName,
    required this.stopLat,
    required this.stopLon,
  });
}

class BusMarker extends Marker {
  final String name;
  final VoidCallback? onTap;
  final Function(double, double) onSetDestination;
  final BuildContext context;

  BusMarker({
    required this.name,
    required LatLng point,
    required this.onSetDestination,
    required this.context,
    Builder? builder,
    height,
    this.onTap,
  }) : super(
          point: point,
          height: 20.0,
          builder: (context) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Bus stop information'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Bus Stop Name: $name'),
                          Text(
                              'Latitude: ${point.latitude}, Longitude: ${point.longitude}')
                          // Text('Additional Information 2: ...'),
                          // Add more Text widgets or other widgets as needed
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                        TextButton(
                          onPressed: () {
                            onSetDestination(point.latitude, point.longitude);
                            print("Destination now is ${name}");
                            Navigator.of(context).pop();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DestinationScreen(
                                    destinationPosition:
                                        LatLng(point.latitude, point.longitude),
                                  ),
                                ));
                          },
                          child: Text('Set as destination'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: CustomMarkerIcon(),
            );
          },
        );
}

class MarkerData {
  final BuildContext context;
  MarkerData(this.context);
  Future<List<BusMarker>> generateMarkers(
      String fileName, Function(double, double) onSetDestination) async {
    List<StopInfo> stopsList = await _parseStopsFromFile(fileName);

    List<BusMarker> markers = [];

    for (var stop in stopsList) {
      BusMarker marker = BusMarker(
        name: stop.stopName,
        point: LatLng(stop.stopLat, stop.stopLon),
        onSetDestination: onSetDestination,
        context: context,
      );
      markers.add(marker);
    }

    return markers;
  }

  Future<List<StopInfo>> _parseStopsFromFile(String fileName) async {
    List<StopInfo> stopsList = [];

    try {
      String data = await rootBundle.loadString(fileName);
      List<List<dynamic>> csvTable =
          const CsvToListConverter(eol: "\n").convert(data);

      for (var row in csvTable) {
        // Assuming stop_name, stop_lat, and stop_lon are always at index 2, 4, and 5 respectively
        // print(row[2]);
        String stopName = row[2].replaceAll('"', '').trim();
        double stopLat = double.parse(row[4].toString());
        double stopLon = double.parse(row[5].toString());

        StopInfo stopInfo = StopInfo(
          stopName: stopName,
          stopLat: stopLat,
          stopLon: stopLon,
        );

        stopsList.add(stopInfo);
      }
    } catch (e) {
      // Handle file read or parsing error here
      print('Error while reading or parsing the file: $e');
    }

    return stopsList;
  }
}

class CustomMarkerIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black87,
          width: 1.0,
        ),
      ),
    );
  }
}
