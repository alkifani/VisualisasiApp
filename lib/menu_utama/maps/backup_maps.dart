import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/maps/config_maps.dart';
import 'package:ta_visualisasi/menu_utama/maps/gps_history.dart';

class MapsApp extends StatefulWidget {
  final String plat;

  const MapsApp({Key? key, required this.plat}) : super(key: key);
  // const MapsApp({Key? key}) : super(key: key);

  @override
  _MapsAppState createState() => _MapsAppState();
}

class _MapsAppState extends State<MapsApp> {
  // final databaseRef = FirebaseDatabase.instance.reference().child("DataGPS");
  final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");
  final Completer<GoogleMapController> _controller = Completer();
  static LatLng? sourceLocation;
  static LatLng? destination;
  // buat tipe maps
  MapType _currentMapType = MapType.normal;
  bool _showTraffic = false;

  // static LatLng sourceLocation = LatLng(0,0); // Inisialisasi dengan default
  // static LatLng destination = LatLng(0,0); // Inisialisasi dengan default

  List<LatLng> polylineCoordinates = [];

  Future<void> getPolyPoints() async {
    if (sourceLocation == null || destination == null) {
      // Jika data tidak lengkap, berhenti.
      return;
    }

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(sourceLocation!.latitude, sourceLocation!.longitude),
      PointLatLng(destination!.latitude, destination!.longitude),
    );
    if (result.points.isNotEmpty) {
      setState(() {
        polylineCoordinates.clear(); // Bersihkan data sebelum menambahkan yang baru
        polylineCoordinates.addAll(result.points.map((point) => LatLng(point.latitude, point.longitude)));
      });
    }
  }

  void getDataAwal() {
    databaseRef.child(widget.plat).limitToFirst(1).onValue.listen((event) {
      //query: databaseRef.orderByChild("plat").equalTo(widget.email),
      // databaseRef
      //     .orderByChild("Time")
      //     .limitToFirst(1)
      //     .onValue
      //     .listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic data = snapshot.value;
      print('Data Awal: $data');
      if (data != null && data is Map<dynamic, dynamic>) {
        var firstData = data.values.first;
        var latitude = firstData["latitude"];
        var longitude = firstData["longitude"];
        if (latitude is double && longitude is double) {
          setState(() {
            sourceLocation = LatLng(latitude, longitude);
          });
          getPolyPoints();
        }
      } else {
        setState(() {
          sourceLocation = null;
          destination = null;
          polylineCoordinates.clear(); // Hapus polyline jika data null
        });
      }
    });
  }

  void getDataAkhir() {
    databaseRef.child(widget.plat).limitToLast(1).onValue.listen((event) {
      // databaseRef
      //     .orderByChild("Time")
      //     .limitToLast(1)
      //     .onValue
      //     .listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic data = snapshot.value;
      print('Data Akhir: $data');
      if (data != null && data is Map<dynamic, dynamic>) {
        var lastData = data.values.first;
        var latitude = lastData["latitude"];
        var longitude = lastData["longitude"];
        print('Source Location: $sourceLocation');
        print('Destination: $destination');
        if (latitude is double && longitude is double) {
          setState(() {
            destination = LatLng(latitude, longitude);
          });
          getPolyPoints();
        } else {
          setState(() {
            destination = null;
            polylineCoordinates.clear(); // Hapus polyline jika data null
          });
        }
      }
    });
  }

  @override
  void initState() {
    getDataAwal(); // Mengambil data awal saat aplikasi dimulai
    getDataAkhir(); // Mengambil data akhir saat aplikasi dimulai
    super.initState();
  }

  // fitur tipe map
  void _changeMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  void _toggleTraffic() {
    setState(() {
      _showTraffic = !_showTraffic;
    });
  }

// untuk menghitung jarak antar kordinat menggunakan rumus Haversine
// Fungsi untuk menghitung jarak antara dua koordinat dalam kilometer
  double calculateDistance(double startLat, double startLong, double endLat, double endLong) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer

    // Konversi sudut ke radian
    double toRadians(double degrees) {
      return degrees * pi / 180;
    }

    // Perbedaan antara latitude dan longitude titik awal dan akhir
    double latDifference = toRadians(endLat - startLat);
    double longDifference = toRadians(endLong - startLong);

    // Rumus Haversine
    double a = pow(sin(latDifference / 2), 2) +
        cos(toRadians(startLat)) * cos(toRadians(endLat)) * pow(sin(longDifference / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Jarak antara dua titik dalam kilometer
    double distance = earthRadius * c;

    return distance;
  }

  @override
  Widget build(BuildContext context) {
    double? distance;
    if (sourceLocation != null && destination != null) {
      distance = calculateDistance(sourceLocation!.latitude, sourceLocation!.longitude, destination!.latitude, destination!.longitude);
    }
    //print('Jarak tempuh: ${distance.toStringAsFixed(2)} kilometer');

    return Scaffold(
      backgroundColor: background,
      // appBar: AppBar(
      //   backgroundColor: const Color.fromRGBO(234, 186, 103, 1.0),
      //   elevation: 0,
      //   title: const Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       Text(
      //         'Visualisasi Perjalanan',
      //         style: TextStyle(color: Colors.black),
      //       ),
      //       SizedBox(width: 10),
      //       Icon(MyFlutterApp.maps, color: Colors.black),
      //     ],
      //   ),
      //   centerTitle: true,
      //   iconTheme: const IconThemeData(color: Colors.black),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: sourceLocation != null && destination != null ?
            Column(
              children: [
                SizedBox(height: 10,),
                Text('Data Lokasi Perjalanan',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 40,
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GPSHistoryDisplay(plat: widget.plat),
                              ),
                            );
                            // Navigator.pushNamed(context, DistanceHistoryDisplay.routeName);
                          },
                          style:ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                button
                              // Color.fromRGBO(69, 69, 69, 1.0)
                            ),
                          ),
                          child:
                          Icon(CupertinoIcons.decrease_indent, color: texticon, size: 18,)
                        // Text("Detail Data", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    SizedBox(width: 10,)
                  ],
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition:
                          CameraPosition(
                            // target: sourceLocation != null ? destination! : LatLng(5.550355540607927, 95.32006799690959),
                            target: destination ?? LatLng(5.550355540607927, 95.32006799690959),
                            zoom: 13.5,
                          ),
                          markers: sourceLocation != null && destination != null
                              ? {
                            Marker(
                              markerId: const MarkerId("source"),
                              position: sourceLocation!,
                            ),
                            Marker(
                              markerId: const MarkerId("destination"),
                              position: destination!,
                            ),
                          }
                              : Set<Marker>(),
                          onMapCreated: (GoogleMapController mapController) {
                            _controller.complete(mapController);
                          },
                          // tipe map
                          myLocationEnabled: false,
                          mapType: _currentMapType,
                          trafficEnabled: _showTraffic,
                          zoomControlsEnabled: false,
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId("route"),
                              points: polylineCoordinates,
                              color: const Color(0xFF7B61FF),
                              width: 6,
                            )
                          },
                        ),
                        Positioned(
                          top: 10,
                          right: 15,
                          child: Column(
                            children: [
                              FloatingActionButton(
                                mini: true,
                                onPressed: _changeMapType,
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                backgroundColor: _currentMapType == MapType.normal ? Colors.white70 : Colors.white70,
                                child: Icon(
                                  _currentMapType == MapType.normal ? Icons.map : Icons.satellite,
                                  size: 25.0, color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 6),
                              FloatingActionButton(
                                mini: true,
                                onPressed: _toggleTraffic,
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                backgroundColor: _showTraffic ? Colors.white70 : Colors.white60,
                                child: Icon(
                                  _showTraffic ? Icons.traffic : Icons.traffic_outlined,
                                  size: 25.0, color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          right: 15,
                          child: Row(
                            children: [
                              FloatingActionButton(
                                onPressed: () async {
                                  final GoogleMapController controller = await _controller.future;
                                  controller.animateCamera(CameraUpdate.zoomIn());
                                },
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                mini: true,
                                backgroundColor: Colors.white70,
                                child: const Icon(Icons.zoom_in, size: 25.0, color: Colors.black),
                              ),
                              SizedBox(width: 6),
                              FloatingActionButton(
                                onPressed: () async {
                                  final GoogleMapController controller = await _controller.future;
                                  controller.animateCamera(CameraUpdate.zoomOut());
                                },
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                mini: true,
                                backgroundColor: Colors.white70,
                                child: const Icon(Icons.zoom_out, size: 25.0, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text('Jarak Tempuh: ${distance != null ? distance.toStringAsFixed(2) : 'Data tidak tersedia'} Km'),

              ],
            ) : Center(
              child: Text(
                'Data Tidak Tersedia',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
