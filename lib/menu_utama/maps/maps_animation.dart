import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/maps/config_maps.dart';
import 'package:ta_visualisasi/menu_utama/maps/gps_history.dart';

class MapsApp extends StatefulWidget {
  final String plat;

  const MapsApp({Key? key, required this.plat}) : super(key: key);

  @override
  _MapsAppState createState() => _MapsAppState();
}

class _MapsAppState extends State<MapsApp> {
  final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");
  final Completer<GoogleMapController> _controller = Completer();
  static LatLng? sourceLocation;
  static LatLng? destination;
  MapType _currentMapType = MapType.normal;
  bool _showTraffic = false;
  List<LatLng> polylineCoordinates = [];

  Future<void> getPolyPoints() async {
    if (sourceLocation == null || destination == null) {
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
        polylineCoordinates.clear();
        polylineCoordinates.addAll(result.points.map((point) => LatLng(point.latitude, point.longitude)));
      });
    }
  }

  void getData({DateTime? startDate, DateTime? endDate}) {
    Query query = databaseRef.child(widget.plat).orderByChild('DateUnggah').limitToLast(1);
    if (startDate != null && endDate != null) {
      query = databaseRef
          .child(widget.plat)
          .orderByChild('DateUnggah')
          .startAt(startDate.millisecondsSinceEpoch)
          .endAt(endDate.millisecondsSinceEpoch);
    }

    query.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic data = snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        var latestJourney = data.values.last;
        if (latestJourney is Map<dynamic, dynamic>) {
          var journeyData = latestJourney.values.firstWhere((element) => element is Map<dynamic, dynamic>, orElse: () => null);
          if (journeyData != null && journeyData is Map<dynamic, dynamic>) {
            var latitudeStart = journeyData['latitude'];
            var longitudeStart = journeyData['longitude'];
            var latitudeEnd = latestJourney.values.last['latitude'];
            var longitudeEnd = latestJourney.values.last['longitude'];
            if (latitudeStart is double && longitudeStart is double && latitudeEnd is double && longitudeEnd is double) {
              setState(() {
                sourceLocation = LatLng(latitudeStart, longitudeStart);
                destination = LatLng(latitudeEnd, longitudeEnd);
              });
              getPolyPoints();
            }
          }
        }
      } else {
        setState(() {
          sourceLocation = null;
          destination = null;
          polylineCoordinates.clear();
        });
      }
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  void _toggleTraffic() {
    setState(() {
      _showTraffic = !_showTraffic;
    });
  }


  double calculateDistance(double startLat, double startLong, double endLat, double endLong) {
    const double earthRadius = 6371;

    double toRadians(double degrees) {
      return degrees * pi / 180;
    }

    double latDifference = toRadians(endLat - startLat);
    double longDifference = toRadians(endLong - startLong);

    double a = pow(sin(latDifference / 2), 2) +
        cos(toRadians(startLat)) * cos(toRadians(endLat)) * pow(sin(longDifference / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    return distance;
  }

  @override
  Widget build(BuildContext context) {
    double? distance;
    if (sourceLocation != null && destination != null) {
      distance = calculateDistance(sourceLocation!.latitude, sourceLocation!.longitude, destination!.latitude, destination!.longitude);
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text(
                  // 'Data Lokasi Perjalanan',
                  'Vehicle Location Data',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
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
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(button),
                        ),
                        child: Icon(CupertinoIcons.decrease_indent, color: texticon, size: 18,),
                      ),
                    ),
                    SizedBox(width: 10,),
                    SizedBox(
                      height: 30,
                      width: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenMap(
                                sourceLocation: sourceLocation,
                                destination: destination,
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(button),
                        ),
                          child: Icon(CupertinoIcons.fullscreen, color: texticon, size: 18,)
                      ),
                    ),
                    SizedBox(width: 10,),
                  ],
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            // target: destination ?? LatLng(5.550355540607927, 95.32006799690959),
                            target: sourceLocation ?? LatLng(5.550355540607927, 95.32006799690959),
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
                          myLocationEnabled: false,
                          mapType: _currentMapType,
                          trafficEnabled: _showTraffic,
                          zoomControlsEnabled: false,
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId("route"),
                              points: polylineCoordinates,
                              color: Colors.black54,
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
                          left: 15,
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
                Expanded(
                  flex: 0,
                  child: distance != null ? Center(
                    child: Text(
                      // 'Jarak Perjalanan: '
                      'Distance Travelled: '
                          '${distance.toStringAsFixed(2)} km',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ) : Center(
                    child: Text(
                      'Retrieving Data...',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// full_screen_map.dart

class FullScreenMap extends StatefulWidget {
  final LatLng? sourceLocation;
  final LatLng? destination;

  const FullScreenMap({Key? key, this.sourceLocation, this.destination}) : super(key: key);

  @override
  _FullScreenMapState createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  MapType _currentMapType = MapType.normal;
  bool _showTraffic = false;

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  void _toggleTraffic() {
    setState(() {
      _showTraffic = !_showTraffic;
    });
  }

  Future<void> getPolyPoints() async {
    if (widget.sourceLocation == null || widget.destination == null) {
      return;
    }

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(widget.sourceLocation!.latitude, widget.sourceLocation!.longitude),
      PointLatLng(widget.destination!.latitude, widget.destination!.longitude),
    );

    if (result.points.isNotEmpty) {
      setState(() {
        polylineCoordinates.clear();
        polylineCoordinates.addAll(result.points.map((point) => LatLng(point.latitude, point.longitude)));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: texticon),
        title: Text('Vehicle Location Data',
          style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),),
        backgroundColor: header,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.sourceLocation ?? LatLng(0, 0),
              zoom: 13.5,
            ),
            markers: widget.sourceLocation != null && widget.destination != null
                ? {
              Marker(
                markerId: const MarkerId("source"),
                position: widget.sourceLocation!,
              ),
              Marker(
                markerId: const MarkerId("destination"),
                position: widget.destination!,
              ),
            }
                : Set<Marker>(),
            onMapCreated: (GoogleMapController mapController) {
              _controller.complete(mapController);
            },
            myLocationEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: polylineCoordinates,
                color: Colors.black54,
                width: 6,
              ),
            },
          ),
          Stack(
            children: [
              Positioned(
                top: 15,
                right: 18,
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
                bottom: 45,
                left: 20,
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
        ],
      ),
    );
  }
}

