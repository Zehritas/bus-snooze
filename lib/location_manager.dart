import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';

class LocationManager {
  String? currentAddress;
  Position? currentPosition;
  // LatLng? currentLatLng;
  late final StreamController<LocationMarkerPosition> positionStreamController;
  late final StreamSubscription<Position> locationSubscription;
  LocationManager() {
    positionStreamController =
        StreamController<LocationMarkerPosition>.broadcast();
  }
  // Add a private constructor
  LocationManager._privateConstructor() {
    positionStreamController =
        StreamController<LocationMarkerPosition>.broadcast();
  }

  // Create a static instance of LocationManager
  static final LocationManager _instance =
      LocationManager._privateConstructor();

  // Add a static getter to access the instance
  static LocationManager get instance => _instance;

  // void startListeningForLocation() async {
  //   final hasPermission = await handleLocationPermission();
  //   // updateLocation();
  //   var locationSettings = const LocationSettings(
  //     accuracy: LocationAccuracy.best,
  //     distanceFilter: 0,
  //     timeLimit: Duration(seconds: 30),
  //   );
  //   var androidSettings = AndroidSettings(
  //     accuracy: LocationAccuracy.best,
  //     distanceFilter: 0,
  //     intervalDuration: Duration(seconds: 20),
  //   );
  //   locationSubscription =
  //       Geolocator.getPositionStream(locationSettings: androidSettings)
  //           .listen((Position position) {
  //     if (position != null) {
  //       currentPosition = position;
  //       // getAddressFromLatLng(currentPosition!);

  //       positionStreamController.add(LocationMarkerPosition(
  //         latitude: currentPosition!.latitude,
  //         longitude: currentPosition!.longitude,
  //         accuracy: position.accuracy,
  //       ));
  //       // setState((){});
  //       print(
  //           "Location has changed; ${position.latitude}, ${position.latitude}");
  //     }
  //   });
  // }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position? position) {
      if (position != null) {
        currentPosition = position;
        // getAddressFromLatLng(currentPosition!);
      }
    }).catchError((e) {
      debugPrint(e);
    });
  }

  // Future<void> getAddressFromLatLng(Position position) async {
  //   await placemarkFromCoordinates(
  //           currentPosition!.latitude, currentPosition!.longitude)
  //       .then((List<Placemark> placemarks) {
  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks[0];
  //       currentAddress = '${place.street}';
  //     }
  //   }).catchError((e) {
  //     debugPrint(e);
  //   });
  // }

  Future<void> updateLocation() async {
    await getCurrentPosition();
    if (currentPosition != null) {
      // await getAddressFromLatLng(currentPosition!);
      // currentLatLng =
      //     LatLng(currentPosition!.latitude, currentPosition!.longitude);

      if (currentPosition != null) {
        positionStreamController.add(LocationMarkerPosition(
          latitude: currentPosition!.latitude,
          longitude: currentPosition!.longitude,
          accuracy: currentPosition!.accuracy,
        ));
      } else {
        // Handle the case where currentLatLng is null
        // You can print an error message or take appropriate action
      }
    }
    // print(durationText);
    // print('$positionNow');
    // print('$addressNow');
    // print('${LocationManager.currentPosition}');
    // print('${LocationManager.currentAddress}');
  }

  Future<void> updateETA(double currentLatitude, double currentLongitude,
      double destinationLatitude, double destinationLongitude) async {
    Dio dio = new Dio();
    try {
      // Extract latitude and longitude values from the Position objects
      // double currentLatitude = this.des.latitude;
      // double currentLongitude = currentPosition.longitude;
      // double destinationLatitude = destinationPosition.latitude;
      // double destinationLongitude = destinationPosition.longitude;
      // Construct the URL using the extracted latitude and longitude values
      String url =
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$currentLatitude,$currentLongitude&destinations=$destinationLatitude,$destinationLongitude&key=AIzaSyAsu3ger-jQLY_5K9XySthyRBRIhgiMO_A";

      Response response = await dio.get(url);
      Map<String, dynamic> responseData = response.data;

      // Check if the status in the response is "OK"
      if (responseData["status"] == "OK") {
        // Extract the duration text (e.g., "6 mins") from the response
        String durationText =
            responseData["rows"][0]["elements"][0]["duration"]["text"];
        String distanceText =
            responseData["rows"][0]["elements"][0]["distance"]["text"];
        print("Estimated arrival time: $durationText");
        print("Distance left: $distanceText");
      } else {
        // Handle other status values if needed
        print("Error: Unable to get ETA");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
  // Future<void> updateEverythingTest() async {
  //   // Update the position
  //   await getCurrentPosition();
  //   // Update the address based on the new position
  //   await getAddressFromLatLng(currentPosition!);
  // }
}
