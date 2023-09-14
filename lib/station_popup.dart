// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'markers_data.dart';

// class StationPopup extends StatefulWidget {
//   final Marker marker;

//   const StationPopup(this.marker, {Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _StationPopupState();
// }

// class _StationPopupState extends State<StationPopup> {
//   final List<IconData> _icons = [
//     Icons.star_border,
//     Icons.star_half,
//     Icons.star
//   ];
//   int _currentIcon = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: InkWell(
//         onTap: () => setState(() {
//           _currentIcon = (_currentIcon + 1) % _icons.length;
//         }),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.only(left: 20, right: 10),
//               child: Icon(_icons[_currentIcon]),
//             ),
//             _cardDescription(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _cardDescription(BuildContext context) {
//     MarkerData test = MarkerData();
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: Container(
//         constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             const Text(
//               'Jus gejai visidd esat nx',
//               overflow: TextOverflow.fade,
//               softWrap: false,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14.0,
//               ),
//             ),
//             const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
//             Text(
//               'Position: ${widget.marker.point.longitude}, ${widget.marker.point.longitude}, ${widget.marker}',
//               style: const TextStyle(fontSize: 12.0),
//             ),
//             // Text(
//             // 'Marker size: ${test.markersMap[widget.marker]}, ${widget.marker.height}',
//             // style: const TextStyle(fontSize: 12.0),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }


  // Future<void> updateETA(double currentLatitude, double currentLongitude,
  //     double destinationLatitude, double destinationLongitude) async {
  //   Dio dio = new Dio();
  //   try {
  //     // Extract latitude and longitude values from the Position objects
  //     // double currentLatitude = this.des.latitude;
  //     // double currentLongitude = currentPosition.longitude;
  //     // double destinationLatitude = destinationPosition.latitude;
  //     // double destinationLongitude = destinationPosition.longitude;
  //     // Construct the URL using the extracted latitude and longitude values
  //     String url =
  //         "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$currentLatitude,$currentLongitude&destinations=$destinationLatitude,$destinationLongitude&key=AIzaSyAsu3ger-jQLY_5K9XySthyRBRIhgiMO_A";

  //     Response response = await dio.get(url);
  //     Map<String, dynamic> responseData = response.data;

  //     // Check if the status in the response is "OK"
  //     if (responseData["status"] == "OK") {
  //       // Extract the duration text (e.g., "6 mins") from the response
  //       String durationText =
  //           responseData["rows"][0]["elements"][0]["duration"]["text"];
  //       String distanceText =
  //           responseData["rows"][0]["elements"][0]["distance"]["text"];
  //       print("Estimated arrival time: $durationText");
  //       print("Distance left: $distanceText");
  //     } else {
  //       // Handle other status values if needed
  //       print("Error: Unable to get ETA");
  //       return null;
  //     }
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }