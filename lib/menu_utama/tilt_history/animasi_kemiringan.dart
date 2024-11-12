import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:ta_visualisasi/configure/constants.dart';

class AnimasiKemiringan extends StatefulWidget {
  final String plat;

  const AnimasiKemiringan({Key? key, required this.plat}) : super(key: key);

  @override
  State<AnimasiKemiringan> createState() => _AnimasiKemiringanState();
}

class _AnimasiKemiringanState extends State<AnimasiKemiringan> {
  late Scene _scene;
  Object? _cube;
  double xPosisi = 0.0;
  double yPosisi = 0.0;
  double zPosisi = 0.0;
  double xRotasi = 0.0;
  double yRotasi = 0.0;
  double zRotasi = 0.0;

  void _onSceneCreated2(Scene scene) {
    _scene = scene;
    scene.camera.position.z = 20;
    scene.camera.target.y = 2;
    _cube = Object(
        scale: Vector3(10.0, 10.0, 10.0),
        backfaceCulling: false,
        fileName: 'assets/images/mobil.obj',
        lighting: true,
        rotation: Vector3(0, -138, 0)
    );
    scene.world.add(_cube!);
  }

  void _updateCubeRotation() {
    if (_cube != null) {
      _cube!.rotation.x = xRotasi;
      _cube!.rotation.y = yRotasi;
      _cube!.rotation.z = zRotasi;
      _cube!.updateTransform();
      _scene.update();
    }
  }

  void _updateCubePosisi() {
    if (_cube != null) {
      _cube!.position.x = xPosisi;
      _cube!.position.y = yPosisi;
      _cube!.position.z = zPosisi;
      _cube!.updateTransform();
      _scene.update();
    }
  }

  void _resetPositionAndRotation() {
    setState(() {
      xPosisi = 0.0;
      yPosisi = 0.0;
      zPosisi = 0.0;
      xRotasi = 0.0;
      yRotasi = -138;
      zRotasi = 0.0;
      _updateCubeRotation();
      _updateCubePosisi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        iconTheme: IconThemeData(color: texticon),
        title: Text('Simulasi 3D', style: TextStyle(color: textheader),),
      ),
      body: Column(
        children: [
          Expanded(
            child: Cube(
              onSceneCreated: _onSceneCreated2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text('Rotate X:'),
                          Slider(
                            value: xRotasi,
                            min: -180,
                            max: 180,
                            divisions: 360,
                            label: xRotasi.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                xRotasi = value;
                                _updateCubeRotation();
                              });
                            },
                          ),
                          Text('Rotate Y:'),
                          Slider(
                            value: yRotasi,
                            min: -180,
                            max: 180,
                            divisions: 360,
                            label: yRotasi.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                yRotasi = value;
                                _updateCubeRotation();
                              });
                            },
                          ),
                          Text('Rotate Z:'),
                          Slider(
                            value: zRotasi,
                            min: -180,
                            max: 180,
                            divisions: 360,
                            label: zRotasi.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                zRotasi = value;
                                _updateCubeRotation();
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Posisi X:'),
                          Slider(
                            value: xPosisi,
                            min: -10,
                            max: 10,
                            divisions: 10,
                            label: xPosisi.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                xPosisi = value;
                                _updateCubePosisi();
                              });
                            },
                          ),
                          Text('Posisi Y:'),
                          Slider(
                            value: yPosisi,
                            min: -10,
                            max: 10,
                            divisions: 10,
                            label: yPosisi.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                yPosisi = value;
                                _updateCubePosisi();
                              });
                            },
                          ),
                          Text('Posisi Z:'),
                          Slider(
                            value: zPosisi,
                            min: -10,
                            max: 10,
                            divisions: 10,
                            label: zPosisi.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                zPosisi = value;
                                _updateCubePosisi();
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _resetPositionAndRotation,
                        child: Text('Reset Posisi dan Rotasi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
