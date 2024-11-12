import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/configure/my_flutter_app_icons.dart';
import 'package:ta_visualisasi/menu_utama/maps/config_maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class GPSHistoryDisplay extends StatefulWidget {
  final String plat;

  const GPSHistoryDisplay({Key? key, required this.plat}) : super(key: key);

  @override
  State<GPSHistoryDisplay> createState() => _GPSHistoryDisplayState();
}

class _GPSHistoryDisplayState extends State<GPSHistoryDisplay> {
  final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> _markers = {};

  static const LatLng defaultLocation = LatLng(5.550355540607927, 95.32006799690959);

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(defaultLocation.latitude, defaultLocation.longitude),
      PointLatLng(defaultLocation.latitude, defaultLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
            (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _moveToLocation(double? latitude, double? longitude, String? time) async {
    if (latitude != null && longitude != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(latitude, longitude),
          15.0,
        ),
      );

      final MarkerId markerId = MarkerId(time ?? '');
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: 'Time: $time'),
      );

      setState(() {
        _markers.removeWhere((key, value) => key == markerId);
        _markers[markerId] = marker;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Invalid location data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  _buildNoDataAvailableMessage() {
    return Center(
      child: Text(
        "Data Not Available", textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  void initState() {
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Location Data',
              style: TextStyle(color: textheader),
            ),
            SizedBox(width: 10),
            Icon(MyFlutterApp.maps, color: texticon),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: texticon),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FirebaseAnimatedList(
                query: databaseRef.child(widget.plat).orderByChild('DateUnggah').limitToLast(1),
                itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
                  dynamic value = snapshot.value;
                  if (!(value is Map<dynamic, dynamic>)) {
                    return Container();
                  }
                  List<Map<dynamic, dynamic>> journeys = [];
                  value.forEach((key, value) {
                    if (value is Map<dynamic, dynamic>) {
                      journeys.add(value);
                    }
                  });

                  // Filter out journeys with null datetime
                  journeys = journeys.where((journey) => journey['datetime'] != null).toList();

                  if (journeys.isEmpty) {
                    return _buildNoDataAvailableMessage();
                  }

                  // Sort list of journeys by datetime
                  journeys.sort((a, b) => a['datetime'].compareTo(b['datetime']));

                  return Column(
                    children: journeys.map<Widget>((journey) {
                      String? latitude = journey['latitude']?.toString();
                      String? longitude = journey['longitude']?.toString();
                      String? datetime = journey['datetime']?.toString();

                      if (latitude == null || longitude == null || datetime == null) {
                        return SizedBox(); // Mengabaikan entri yang tidak valid
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              "Time: $datetime",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Data Latitude: ${double.tryParse(latitude)?.toStringAsFixed(8) ?? ''}',
                                    ),
                                    Text(
                                      'Data Longitude: ${double.tryParse(longitude)?.toStringAsFixed(8) ?? ''}',
                                    ),
                                  ],
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _moveToLocation(double.tryParse(latitude), double.tryParse(longitude), datetime);
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all<Color>(button),
                                  ),
                                  child: const Text("View on Map", style: TextStyle(color: textbutton)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: defaultLocation,
                      zoom: 13.5,
                    ),
                    markers: _markers.values.toSet(),
                    onMapCreated: (mapController) {
                      _controller.complete(mapController);
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: polylineCoordinates,
                        color: const Color(0xFF7B61FF),
                        width: 6,
                      )
                    },
                  ),
                ),
              ),
            ),
            //SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}


// import 'dart:async';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:flutter/material.dart';
// import 'package:ta_visualisasi/configure/constants.dart';
// import 'package:ta_visualisasi/configure/my_flutter_app_icons.dart';
// import 'package:ta_visualisasi/menu_utama/maps/config_maps.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// class GPSHistoryDisplay extends StatefulWidget {
//   // static String routeName = "/gps_history";
//   // const GPSHistoryDisplay({Key? key}) : super(key: key);
//   final String plat;
//
//   const GPSHistoryDisplay({Key? key, required this.plat}) : super(key: key);
//
//   @override
//   State<GPSHistoryDisplay> createState() => _GPSHistoryDisplayState();
// }
//
// class _GPSHistoryDisplayState extends State<GPSHistoryDisplay> {
//   // final databaseRef = FirebaseDatabase.instance.reference().child("DataGPS");
//   final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");
//   Completer<GoogleMapController> _controller = Completer();
//
//   Future<void> _moveToLocation(double? latitude, double? longitude, String? time) async {
//     if (latitude != null && longitude != null) {
//       final GoogleMapController controller = await _controller.future;
//       controller.animateCamera(
//         CameraUpdate.newLatLngZoom(
//           LatLng(latitude, longitude),
//           15.0,
//         ),
//       );
//
//       // Tambahkan marker untuk lokasi yang sesuai
//       final MarkerId markerId = MarkerId(time ?? ''); // Menggunakan waktu sebagai ID unik
//       final Marker marker = Marker(
//         markerId: markerId,
//         position: LatLng(latitude, longitude),
//         infoWindow: InfoWindow(title: 'Time: $time'),
//       );
//
//       setState(() {
//         // Hapus marker sebelumnya jika ada
//         _markers.removeWhere((key, value) => key == markerId);
//         // Tambahkan marker baru
//         _markers[markerId] = marker;
//       });
//     }
//   }
//
//   // Tambahkan _markers untuk menyimpan semua marker pada peta
//   Map<MarkerId, Marker> _markers = {};
//
//   List<LatLng> polylineCoordinates = [];
//
//   void getPolyPoints() async {
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleApiKey, // Ganti dengan kunci Google Map Anda
//       PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
//       PointLatLng(destination.latitude, destination.longitude),
//     );
//     if (result.points.isNotEmpty) {
//       result.points.forEach(
//             (PointLatLng point) => polylineCoordinates.add(
//           LatLng(point.latitude, point.longitude),
//         ),
//       );
//       setState(() {});
//     }
//   }
//
//   static const LatLng sourceLocation = LatLng(0, 0);
//   static const LatLng destination = LatLng(0, 0);
//
//   _buildNoDataAvailableMessage() {
//     return Center(
//       child: Text(
//         "Data Tidak Tersedia", textAlign: TextAlign.center,
//         style: TextStyle(fontSize: 18),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     getPolyPoints();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: header,
//         elevation: 0,
//         title: const Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Text(
//               'Data Lokasi',
//               style: TextStyle(color: textheader),
//             ),
//             SizedBox(width: 10),
//             Icon(MyFlutterApp.maps, color: texticon),
//           ],
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: texticon),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: FirebaseAnimatedList(
//                 query: databaseRef.child(widget.plat).orderByChild('DateUnggah').limitToLast(1),
//                 itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
//                   dynamic value = snapshot.value;
//                   if (!(value is Map<dynamic, dynamic>)) {
//                     return Container();
//                   }
//                   List<Map<dynamic, dynamic>> journeys = [];
//                   value.forEach((key, value) {
//                     if (value is Map<dynamic, dynamic>) {
//                       journeys.add(value);
//                     }
//                   });
//
//                   // Urutkan list perjalanan berdasarkan datetime
//                   journeys.sort((a, b) => a['datetime'].compareTo(b['datetime']));
//
//                   return Column(
//                     children: journeys.map<Widget>((journey) {
//                       String? latitude = journey['latitude']?.toString();
//                       String? longitude = journey['longitude']?.toString();
//                       String? datetime = journey['datetime'] as String;
//
//                       if (latitude == null || longitude == null || datetime == null ) {
//                         return SizedBox(); // Mengabaikan entri yang tidak valid
//                       }
//
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Card(
//                           elevation: 2,
//                           child: ListTile(
//                             title: Text(
//                               "Time: $datetime",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Data Latitude: ${double.tryParse(latitude)?.toStringAsFixed(8) ?? ''}',
//                                     ),
//                                     Text(
//                                       'Data Longitude: ${double.tryParse(longitude)?.toStringAsFixed(8) ?? ''}',
//                                     ),
//                                   ],
//                                 ),
//
//                                 SizedBox(width: 20),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     _moveToLocation(double.tryParse(latitude), double.tryParse(longitude), datetime);
//                                   },
//                                   style: ButtonStyle(
//                                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                       RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                     ),
//                                     backgroundColor: MaterialStateProperty.all<Color>(
//                                         button
//                                       //Color.fromRGBO(69, 69, 69, 1.0),
//                                     ),
//                                   ),
//                                   child: const Text("View on Map", style: TextStyle(color: Colors.black)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   );
//
//                   // String? latitude = value['latitude']?.toString();
//                   // String? longitude = value['longitude']?.toString();
//                   // String? time = value['datetime'] as String?;
//                   // if (latitude == null || longitude == null || time == null) {
//                   //   return const SizedBox();
//                   // }
//                   // return Padding(
//                   //   padding: const EdgeInsets.all(8.0),
//                   //   child: Card(
//                   //     elevation: 2,
//                   //     child: ListTile(
//                   //       title: Text('Time: $time'),
//                   //       subtitle: Column(
//                   //         crossAxisAlignment: CrossAxisAlignment.start,
//                   //         children: [
//                   //           const SizedBox(height: 10),
//                   //           Text(
//                   //             'Data Latitude: ${double.tryParse(latitude)?.toStringAsFixed(8) ?? ''}',
//                   //           ),
//                   //           const SizedBox(height: 10),
//                   //           Text(
//                   //             'Data Longitude: ${double.tryParse(longitude)?.toStringAsFixed(8) ?? ''}',
//                   //           ),
//                   //           const SizedBox(height: 20),
//                   //           ElevatedButton(
//                   //             onPressed: () {
//                   //               _moveToLocation(double.tryParse(latitude), double.tryParse(longitude), time);
//                   //             },
//                   //             style: ButtonStyle(
//                   //               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                   //                 RoundedRectangleBorder(
//                   //                   borderRadius: BorderRadius.circular(20),
//                   //                 ),
//                   //               ),
//                   //               backgroundColor: MaterialStateProperty.all<Color>(
//                   //                 button
//                   //                 //Color.fromRGBO(69, 69, 69, 1.0),
//                   //               ),
//                   //             ),
//                   //             child: const Text("View on Map", style: TextStyle(color: Colors.black)),
//                   //           ),
//                   //         ],
//                   //       ),
//                   //     ),
//                   //   ),
//                   // );
//                 },
//               ),
//             ),
//             SizedBox(height: 5),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: sourceLocation,
//                     zoom: 13.5,
//                   ),
//                   markers: _markers.values.toSet(), // Menggunakan semua marker yang telah ditambahkan
//                   onMapCreated: (mapController) {
//                     _controller.complete(mapController);
//                   },
//                   polylines: {
//                     Polyline(
//                       polylineId: const PolylineId("route"),
//                       points: polylineCoordinates,
//                       color: const Color(0xFF7B61FF),
//                       width: 6,
//                     )
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: 5),
//           ],
//         ),
//       ),
//     );
//   }
// }
