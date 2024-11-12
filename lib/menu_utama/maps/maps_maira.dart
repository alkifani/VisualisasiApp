import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';

const String googleApiKey = 'AIzaSyCnsM79Dr9OZ-m6xG71dBvyFfzQfSuUuBE';

class MapsApp extends StatefulWidget {
  final String email;
  final String journey;

  const MapsApp({Key? key, required this.email, required this.journey}) : super(key: key);

  @override
  _MapsAppState createState() => _MapsAppState();
}

class _MapsAppState extends State<MapsApp> {
  final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  double totalDistance = 0.0;
  Duration totalTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    databaseRef.child(widget.email).child(widget.journey).onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      var journeyData = snapshot.value;

      if (journeyData != null && journeyData is Map<dynamic, dynamic>) {
        List<dynamic> journeyList = journeyData.values.toList();
        if (journeyList.isNotEmpty) {
          setState(() {
            polylineCoordinates.clear();
            DateTime? startDateTime;
            DateTime? endDateTime;

            for (var journeyPoint in journeyList) {
              if (journeyPoint is Map<dynamic, dynamic>) {
                var latitude = journeyPoint['latitude'];
                var longitude = journeyPoint['longitude'];
                var dateTimeString = journeyPoint['datetime'];

                if (latitude is double && longitude is double && dateTimeString is String) {
                  polylineCoordinates.add(LatLng(latitude, longitude));

                  DateTime journeyTime = DateTime.parse(dateTimeString);
                  if (startDateTime == null || journeyTime.isBefore(startDateTime)) {
                    startDateTime = journeyTime;
                  }
                  if (endDateTime == null || journeyTime.isAfter(endDateTime)) {
                    endDateTime = journeyTime;
                  }

                  if (polylineCoordinates.length > 1) {
                    totalDistance += _coordinateDistance(
                      polylineCoordinates[polylineCoordinates.length - 2].latitude,
                      polylineCoordinates[polylineCoordinates.length - 2].longitude,
                      latitude,
                      longitude,
                    );
                  }
                }
              }
            }

            if (startDateTime != null && endDateTime != null) {
              totalTime = endDateTime.difference(startDateTime);
            }
          });
        }
      } else {
        setState(() {
          polylineCoordinates.clear();
          totalDistance = 0.0;
          totalTime = Duration.zero;
        });
      }
    });
  }

  double _coordinateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // Distance in kilometers
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                'Data Lokasi Perjalanan',
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: polylineCoordinates.isNotEmpty
                              ? polylineCoordinates.first
                              : LatLng(5.550355540607927, 95.32006799690959),
                          zoom: 13.5,
                        ),
                        markers: polylineCoordinates.isNotEmpty
                            ? {
                          Marker(
                            markerId: const MarkerId("source"),
                            position: polylineCoordinates.first,
                          ),
                          Marker(
                            markerId: const MarkerId("destination"),
                            position: polylineCoordinates.last,
                          ),
                        }
                            : Set<Marker>(),
                        onMapCreated: (GoogleMapController mapController) {
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
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rangkuman Data Perjalanan',
                          ),
                          SizedBox(height: 8),
                          Card(
                            color: Colors.blue.shade100,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(CupertinoIcons.map, color: Colors.blue.shade900),
                                      SizedBox(width: 10),
                                      Text(
                                        'Jarak Tempuh:',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${totalDistance.toStringAsFixed(2)} km',

                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            color: Colors.green.shade100,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(CupertinoIcons.timer, color: Colors.green.shade900),
                                      SizedBox(width: 10),
                                      Text(
                                        'Waktu Tempuh:',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${totalTime.inHours} jam ${totalTime.inMinutes.remainder(60)} menit',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            color: Colors.orange.shade100,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(CupertinoIcons.location, color: Colors.orange.shade900),
                                      SizedBox(width: 10),
                                      Text(
                                        'Poin Mulai:',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${polylineCoordinates.isNotEmpty ? polylineCoordinates.first.latitude.toStringAsFixed(6) : "N/A"}, ${polylineCoordinates.isNotEmpty ? polylineCoordinates.first.longitude.toStringAsFixed(6) : "N/A"}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            color: Colors.red.shade100,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(CupertinoIcons.location_fill, color: Colors.red.shade900),
                                      SizedBox(width: 10),
                                      Text(
                                        'Poin Akhir:',

                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${polylineCoordinates.isNotEmpty ? polylineCoordinates.last.latitude.toStringAsFixed(6) : "N/A"}, ${polylineCoordinates.isNotEmpty ? polylineCoordinates.last.longitude.toStringAsFixed(6) : "N/A"}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Journey Tracker'),
        ),
        body: MapsApp(
          email: 'example@email.com', // Replace with actual email
          journey: 'journey1', // Replace with actual journey ID
        ),
      ),
    ),
  );
}