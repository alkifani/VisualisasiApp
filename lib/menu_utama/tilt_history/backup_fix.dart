import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/tilt_history/animasi_kemiringan.dart';
import 'dart:async';
import 'package:ta_visualisasi/menu_utama/tilt_history/tilt_data_history.dart';

class TiltAnimation extends StatefulWidget {
  final String plat;

  const TiltAnimation({Key? key, required this.plat}) : super(key: key);

  @override
  State<TiltAnimation> createState() => _TiltAnimationState();
}

class _TiltAnimationState extends State<TiltAnimation> {
  final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");

  List<List<double>> _csvTable = [];
  int currentIndex = 0;
  bool isPlaying = false;
  Timer? animationTimer;
  bool isObjectLoaded = false;
  Object? _sceneObject;

  @override
  void initState() {
    super.initState();
    _startDataListener();
  }

  void _startDataListener() {
    databaseRef.child(widget.plat).orderByChild('DateUnggah').limitToLast(1).onValue.listen((event) {
      var snapshot = event.snapshot;
      var value = snapshot.value as Map<dynamic, dynamic>?;
      if (value == null) {
        print("Data is null or empty");
        return;
      }

      List<Map<String, dynamic>> journeyDataList = [];

      value.forEach((key, val) {
        var journey = val as Map<dynamic, dynamic>;
        journey.forEach((key, val) {
          if (val is Map) {
            var acceldatax = double.tryParse(val['accel_data_x'].toString());
            var acceldatay = double.tryParse(val['accel_data_y'].toString());
            var acceldataz = double.tryParse(val['accel_data_z'].toString());
            if (acceldatax == null || acceldatay == null || acceldataz == null) {
              return;
            }

            var gyrodatax = double.tryParse(val['gyro_data_x'].toString());
            var gyrodatay = double.tryParse(val['gyro_data_y'].toString());
            var gyrodataz = double.tryParse(val['gyro_data_z'].toString());
            if (gyrodatax == null || gyrodatay == null || gyrodataz == null) {
              return;
            }

            var datetime = DateTime.tryParse(val['datetime'].toString());
            if (datetime == null) {
              return;
            }

            journeyDataList.add({
              'datetime': datetime,
              'accel_data_x': acceldatax,
              'accel_data_y': acceldatay,
              'accel_data_z': acceldataz,
              'gyro_data_x': gyrodatax,
              'gyro_data_y': gyrodatay,
              'gyro_data_z': gyrodataz,
            });
          }
        });
      });

      journeyDataList.sort((a, b) => a['datetime'].compareTo(b['datetime']));

      setState(() {
        _csvTable = journeyDataList.map((data) => [
          data['accel_data_x'] as double,
          data['accel_data_y'] as double,
          data['accel_data_z'] as double,
          data['gyro_data_x'] as double,
          data['gyro_data_y'] as double,
          data['gyro_data_z'] as double,
        ]).toList();

        print('Data kemiringan: $_csvTable');
        if (!isObjectLoaded) {
          isObjectLoaded = true;
        }

        if (isPlaying) {
          startAnimation();
        }
      });
    });
  }

  void _handlePlayButtonPressed() {
    setState(() {
      isPlaying = true;
      currentIndex = 0;

      if (_csvTable.isNotEmpty) {
        startAnimation();
      } else {
        isPlaying = false; // Don't start animation if _csvTable is empty
      }
    });
  }

  void startAnimation() {
    animationTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        currentIndex++;
        if (currentIndex >= _csvTable.length) {
          stopAnimation();
        } else {
          _updateObjectPositionAndRotation();
        }
      });
    });
  }

  void _updateObjectPositionAndRotation() {
    print('Updating Object Position and Rotation');
    if (isObjectLoaded && currentIndex < _csvTable.length) {
      final currentData = _csvTable[currentIndex];

      print('Current Data from CSV: $currentData');

      if (_sceneObject != null) {
        _sceneObject!.position.setValues(
          currentData[0], // Update X coordinate with accelerometer data
          currentData[1], // Update Y coordinate with accelerometer data
          currentData[2], // Update Z coordinate with accelerometer data
        );
        _sceneObject!.rotation.setValues(
          currentData[3], // Update X rotation with gyroscope data
          currentData[4], // Update Y rotation with gyroscope data
          currentData[5], // Update Z rotation with gyroscope data
        );

        print('Accelerometer Data: -X=${currentData[0]}, Y=${currentData[1]}, Z=${currentData[2]}');
        print('Gyroscope Data: -X=${currentData[3]}, Y=${currentData[4]}, Z=${currentData[5]}');

        print('Updated Object Position: ${_sceneObject!.position}');
        print('Updated Object Rotation: ${_sceneObject!.rotation}');
      } else {
        print("3D objek tidak ditemukan dalam adegan");
      }
    }
  }

  void stopAnimation() {
    animationTimer?.cancel();
    if (mounted) {
      setState(() {
        isPlaying = false;
        currentIndex = 0; // Reset index when animation stops
      });
    }
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text('Visualisasi Animasi Kendaraan',
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
                                builder: (context) => TiltHistoryDisplay(plat: widget.plat),
                              ),
                            );
                          },
                          style:ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                button
                            ),
                          ),
                          child:
                          Icon(CupertinoIcons.decrease_indent, color: texticon, size: 18,)
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
                                builder: (context) => AnimasiKemiringan(plat: widget.plat),
                              ),
                            );
                          },
                          style:ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                button
                            ),
                          ),
                          child:
                          Icon(CupertinoIcons.car_detailed, color: texticon, size: 18,)
                      ),
                    ),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                      if (isPlaying) {
                        _handlePlayButtonPressed();
                      } else {
                        _handleStopButtonPressed();
                      }
                    });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        button
                    ),
                  ),
                  child: isPlaying
                      ? Icon(Icons.pause_sharp, color: Colors.red,)
                      : Icon(Icons.play_arrow_sharp, color: Colors.green,),
                ),
                if (isPlaying)
                  Text("STOP"),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: isObjectLoaded
                        ? ThreeDObject(
                      key: ValueKey(currentIndex),
                      accelDataX: _csvTable[currentIndex][0],
                      accelDataY: _csvTable[currentIndex][1],
                      accelDataZ: _csvTable[currentIndex][2],
                      gyroDataX: _csvTable[currentIndex][3],
                      gyroDataY: _csvTable[currentIndex][4],
                      gyroDataZ: _csvTable[currentIndex][5],
                      onSceneCreated: () {},
                    )
                        : CircularProgressIndicator(),
                  ),
                ),
                if (isPlaying)
                  Text(
                    'Accelerometer Data: X=${_csvTable[currentIndex][0]}, Y=${_csvTable[currentIndex][1]}, Z=${_csvTable[currentIndex][2]}\n'
                        'Gyroscope Data: X=${_csvTable[currentIndex][3]}, Y=${_csvTable[currentIndex][4]}, Z=${_csvTable[currentIndex][5]}',
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStopButtonPressed() {
    stopAnimation();
  }
}

class ThreeDObject extends StatefulWidget {
  final double accelDataX;
  final double accelDataY;
  final double accelDataZ;
  final double gyroDataX;
  final double gyroDataY;
  final double gyroDataZ;
  final VoidCallback onSceneCreated;

  const ThreeDObject({
    Key? key,
    required this.accelDataX,
    required this.accelDataY,
    required this.accelDataZ,
    required this.gyroDataX,
    required this.gyroDataY,
    required this.gyroDataZ,
    required this.onSceneCreated,
  }) : super(key: key);

  @override
  _ThreeDObjectState createState() => _ThreeDObjectState();
}

class _ThreeDObjectState extends State<ThreeDObject> {
  bool isSceneCreated = false;
  Object? _sceneObject;

  @override
  Widget build(BuildContext context) {
    return Cube(
      onSceneCreated: (scene) {
        if (!isSceneCreated) {
          try {
            _sceneObject = Object(
              fileName: 'assets/images/mobil.obj',
              isAsset: true,
              scale: Vector3(4, 4, 4),
              position: Vector3( 0.0,0.0,0.0
                // widget.accelDataX,
                // widget.accelDataY,
                // widget.accelDataZ,
              ),
              rotation: Vector3(
                widget.gyroDataX,
                widget.gyroDataY,
                widget.gyroDataZ,
              ),
            );

            scene.world.add(_sceneObject!);

            setState(() {
              isSceneCreated = true;
              widget.onSceneCreated();
            });
          } catch (error) {
            print("Error loading 3D object: $error");
          }
        } else {
          _sceneObject!.position.setValues( 0.0,0.0,0.0
            // widget.accelDataX,
            // widget.accelDataY,
            // widget.accelDataZ,
          );
          _sceneObject!.rotation.setValues(
            widget.gyroDataX,
            widget.gyroDataY,
            widget.gyroDataZ,
          );
        }
      },
      interactive: true,
    );
  }
}
