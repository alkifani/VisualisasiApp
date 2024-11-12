import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/tilt_history/animasi_kemiringan.dart';
import 'package:ta_visualisasi/menu_utama/tilt_history/kemiringan.dart';
import 'dart:async';
import 'package:ta_visualisasi/menu_utama/tilt_history/tilt_data_history.dart';

class TiltAnimation extends StatefulWidget {
  final String plat;

  const TiltAnimation({Key? key, required this.plat}) : super(key: key);
  // const TiltAnimation({Key? key}) : super(key: key);

  @override
  State<TiltAnimation> createState() => _TiltAnimationState();
}

class _TiltAnimationState extends State<TiltAnimation> {
  // final databaseRef = FirebaseDatabase.instance.reference().child("DataTilt");
  final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");

  List<List<double>> _csvTable = [];
  int currentIndex = 0;
  bool isPlaying = false;
  Timer? animationTimer;
  bool isObjectLoaded = false;

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

      // // Clear existing data
      // _csvTable.clear();

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

        print('data kemiringan $_csvTable');
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
        // Set initial position to desired coordinates
        _csvTable[currentIndex][0] = 0.0;
        _csvTable[currentIndex][1] = 0.0;
        _csvTable[currentIndex][2] = 0.0;
        _csvTable[currentIndex][3] = 0.0;
        _csvTable[currentIndex][4] = 0.0;
        _csvTable[currentIndex][5] = 0.0;
      } else {
        isPlaying = false; // Don't start animation if _csvTable is empty
      }
    });

    if (isPlaying) {
      Future.delayed(Duration(seconds: 1), () {
        startAnimation();
      });
    }
  }

  void startAnimation() {
    animationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        currentIndex++;
        if (currentIndex >= _csvTable.length) {
          stopAnimation();
        }
      });
    });
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
      //backgroundColor: Color.fromRGBO(255, 230, 173, 1.0),
      // appBar: AppBar(
      //   backgroundColor: Color.fromRGBO(234, 186, 103, 1.0),
      //   //backgroundColor: Colors.white,
      //   elevation: 0,
      //   title: const Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       Text(
      //         'Replikasi Visual Kemiringan',
      //         style: TextStyle(color: Colors.black, fontSize: 18),
      //       ),
      //       //SizedBox(width: 10),
      //       Icon(MyFlutterApp.gyroscope, color: Colors.black),
      //     ],
      //   ),
      //   centerTitle: true,
      //   iconTheme: const IconThemeData(color: Colors.black),
      //   // actions: [
      //   //   IconButton(
      //   //     icon: Icon(Icons.play_arrow),
      //   //     onPressed: _handlePlayButtonPressed,
      //   //   ),
      //   //   IconButton(
      //   //     icon: Icon(Icons.stop),
      //   //     onPressed: _handleStopButtonPressed,
      //   //   ),
      //   // ],
      // ),
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
                          Icon(CupertinoIcons.car_detailed, color: texticon, size: 18,)
                        // Text("Detail Data", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      setState(() {
                        isPlaying = !isPlaying; // Mengubah status play/pause saat tombol ditekan.
                        if (isPlaying) {
                          _handlePlayButtonPressed(); // Memanggil fungsi play jika tombol play ditekan.
                        } else {
                          _handleStopButtonPressed(); // Memanggil fungsi stop jika tombol stop ditekan.
                        }
                      });
                    });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      // Color.fromRGBO(246, 233, 195, 1.0)
                        button
                    ),
                  ),
                  child: isPlaying
                      ? Icon(Icons.pause_sharp, color: Colors.red,)
                      : Icon(Icons.play_arrow_sharp, color: Colors.green,),
                  //const Text("Data Kemiringan"),
                ),
                if (isPlaying)
                  Text("STOP"),
                //Text(isPlaying ? "Stop" : "Start"),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: isObjectLoaded
                        ? ThreeDObject(
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
                    'Accelerometer Data: -X=${_csvTable[currentIndex][0]}, Y=${_csvTable[currentIndex][1]}, Z=${_csvTable[currentIndex][2]}\n'
                        'Gyroscope Data: -X=${_csvTable[currentIndex][3]}, Y=${_csvTable[currentIndex][4]}, Z=${_csvTable[currentIndex][5]}',
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
    required this.accelDataX,
    required this.accelDataY,
    required this.accelDataZ,
    required this.gyroDataX,
    required this.gyroDataY,
    required this.gyroDataZ,
    required this.onSceneCreated,
  });

  @override
  _ThreeDObjectState createState() => _ThreeDObjectState();
}

class _ThreeDObjectState extends State<ThreeDObject> {
  bool isSceneCreated = false;

  @override
  Widget build(BuildContext context) {
    return Cube(
      onSceneCreated: (scene) {
        if (!isSceneCreated) {
          try {
            scene.world.add(
              Object(
                fileName: 'assets/images/mobil.obj',
                isAsset: true,
                lighting: true,
                //scale: Vector3(7, 5, 7),
                scale: Vector3(4, 4, 4),
                position: Vector3(
                  // 0.0, // Set initial X coordinate to 0.0
                  // 0.0, // Set initial Y coordinate to 0.0
                  // 0.0, // Set initial Z coordinate to 0.0
                  widget.accelDataX,
                  widget.accelDataY,
                  widget.accelDataZ,
                ),
                rotation: Vector3(
                  // 0.0, // Set initial X coordinate to 0.0
                  // 0.0, // Set initial Y coordinate to 0.0
                  // 0.0, // Set initial Z coordinate to 0.0
                  widget.gyroDataX,
                  widget.gyroDataY,
                  widget.gyroDataZ,
                ),
              ),
            );
            setState(() {
              isSceneCreated = true;
              widget.onSceneCreated();
            });
          } catch (error) {
            print("Error loading 3D object: $error");
          }
        }
      },
      interactive: false,
    );
  }
}
