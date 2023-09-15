import 'dart:async';
import 'dart:math';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:latlong2/latlong.dart';
import 'location_manager.dart';

class DestinationScreen extends StatefulWidget {
  final LatLng destinationPosition;

  DestinationScreen({
    required this.destinationPosition,
  });

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  LocationManager locationManager = LocationManager.instance;
  late Timer _timer;
  double distanceToDestination = 0;
  bool isAlarmActive = false;
  late AlarmSettings alarmSettings;
  final double distanceToAwake = 0.6;

  @override
  void initState() {
    super.initState();
    FlutterBackgroundService().startService();
    locationManager.updateLocation();
    distanceToDestination = calculateDistance(
        locationManager.currentPosition!.latitude,
        locationManager.currentPosition!.longitude,
        widget.destinationPosition.latitude,
        widget.destinationPosition.longitude,
        distanceToDestination);

    final now = DateTime.now(); // Get the current date and time
    final initialDateTime =
        now.toLocal(); // Convert to local time (if necessary)
    alarmSettings = AlarmSettings(
      id: 42,
      dateTime: initialDateTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volumeMax: false,
      fadeDuration: 3.0,
      notificationTitle: 'Bus stop nearby!',
      notificationBody: 'This is the body',
      enableNotificationOnKill: true,
    );
    // Set up a timer to trigger a refresh every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await locationManager.updateLocation();
      distanceToDestination = calculateDistance(
          locationManager.currentPosition!.latitude,
          locationManager.currentPosition!.longitude,
          widget.destinationPosition.latitude,
          widget.destinationPosition.longitude,
          distanceToDestination);
      if (distanceToDestination <= distanceToAwake && !isAlarmActive) {
        triggerAlarm();
      }
      setState(() {}); // Trigger a rebuild
    });
  }

  void triggerAlarm() async {
    final now = DateTime.now();
    final dateTime = now.toLocal();
    alarmSettings = alarmSettings.copyWith(dateTime: dateTime);
    await Alarm.set(alarmSettings: alarmSettings);
    isAlarmActive = true;
    setState(() {}); // Trigger a rebuild
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2,
      double distanceToDestination) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers

    // Convert latitude and longitude from degrees to radians
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c; // Distance in kilometers
    print("${distance}");
    return double.parse(distance.toStringAsFixed(3));
    // distanceToDestination = distance;
  }

  void turnOffAlarm() {
    if (isAlarmActive) {
      Alarm.stop(alarmSettings.id);
      isAlarmActive = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    turnOffAlarm();

    FlutterBackgroundService().invoke('stopService');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destination Screen'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Exit sleep mode?'),
                  content:
                      Text('If you exit now, the alarm will be cancelled!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        turnOffAlarm();
                        Navigator.pop(context, true); // Close the dialog
                        Navigator.pop(context); // Navigate back one screen
                      },
                      child: Text('Yes'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Distance to Destination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${distanceToDestination.toStringAsFixed(3)} km',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            if (isAlarmActive) ...[
              Text(
                "${Alarm.getAlarm(42)!.notificationTitle}",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  turnOffAlarm();
                  Navigator.pop(context); // Close the current screen
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Turn off Alarm',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
