
import 'dart:math';
import 'dart:typed_data';


import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/home_bottom.dart';
import 'package:flutter/cupertino.dart';
import 'package:ta_visualisasi/menu_utama/upload_data/upload_data.dart';

// void main() => runApp(const MyApp());

class DataTransfer extends StatefulWidget {
  // const DataTransfer({Key? key}) : super(key: key);
  final String plat;

  const DataTransfer({Key? key, required this.plat}) : super(key: key);

  @override
  _DataTransferState createState() => _DataTransferState();
}

class _DataTransferState extends State<DataTransfer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: leadingcolor,
              // size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeBottom(plat: widget.plat),
                ),
              );
              // Navigator.of(context).pushAndRemoveUntil(
              //   MaterialPageRoute(builder: (context) => HomeScreen(email: widget.email)),
              //       (Route<dynamic> route) => false,
              // );
            },
          ),
          backgroundColor: header,
          // backgroundColor: Color.fromRGBO(234, 186, 103, 1.0),
          title: const Text('Transfer Data', style: TextStyle(color: texticon),),
          iconTheme: IconThemeData(color: texticon),
        ),
        body: TransferData(plat: widget.plat,),
      ),
    );
  }
}

class TransferData extends StatefulWidget {
  // const TransferData({Key? key}) : super(key: key);
  final String plat;

  const TransferData({Key? key, required this.plat}) : super(key: key);

  @override
  _TransferDataState createState() => _TransferDataState();
}

class _TransferDataState extends State<TransferData> {
  // final String userName = Random().nextInt(10000).toString();
  final Strategy strategy = Strategy.P2P_STAR;
  Map<String, ConnectionInfo> endpointMap = {};

  String? tempFileUri; // Reference to the file currently being transferred
  Map<int, String> map = {}; // Store filename mapped to corresponding payloadId

  bool locationPermissionEnabled = false;
  bool storagePermissionEnabled = false;
  bool manageExternalStorageEnable = false;
  bool bluetoothPermissionEnabled = false;
  bool nearbyPermissionEnabled = false;

  @override
  void initState() {
    super.initState();
    // Check initial permission status
    _checkInitialPermissions();
  }

  void _togglePermissions(bool value) async {
    if (value) {
      // Izinkan izin dan perbarui status widget berdasarkan izin yang diberikan
      final statuslokasi = await Permission.location.request();
      final statusstorage = await Permission.storage.request();
      final statuspenyimpanan = await Permission.manageExternalStorage.request();
      final statuses = await [
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan
      ].request();
      final statusnearby = await Permission.nearbyWifiDevices.request();

      setState(() {
        // Set location permission enabled if granted
        locationPermissionEnabled = statuslokasi.isGranted;

        // Set storage permission enabled if granted
        storagePermissionEnabled = statusstorage.isGranted || statuspenyimpanan.isGranted;

        // Set bluetooth permission enabled if all are granted
        bluetoothPermissionEnabled = statuses.values.every((status) => status.isGranted);

        // Set nearby permission enabled if granted
        nearbyPermissionEnabled = statusnearby.isGranted;
      });
    } else {
      // Revoke permissions if switch is turned off
      final revokedStatuses = await [
        Permission.location,
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.nearbyWifiDevices,
      ].request().then((statuses) => statuses.values.every((status) => !status.isGranted));

      if (revokedStatuses) {
        setState(() {
          // Reset all permissions to disabled
          locationPermissionEnabled = false;
          storagePermissionEnabled = false;
          bluetoothPermissionEnabled = false;
          nearbyPermissionEnabled = false;
          // locationPermissionEnabled = false;
          // storagePermissionEnabled = false;
          // bluetoothPermissionEnabled = false;
          // nearbyPermissionEnabled = false;
        });
      }
    }
  }

// Inside initState method to check initial permissions
  _checkInitialPermissions() async {
    // Check and update the state for each permission
    final locationStatus = await Permission.location.status;
    final storageStatus = await Permission.storage.status;
    final manageExternalStorageStatus = await Permission.manageExternalStorage.status;
    final bluetoothStatus = await Permission.bluetooth.status;
    final nearbyStatus = await Permission.nearbyWifiDevices.status;

    setState(() {
      locationPermissionEnabled = locationStatus.isGranted;
      storagePermissionEnabled = storageStatus.isGranted || manageExternalStorageStatus.isGranted;
      bluetoothPermissionEnabled = bluetoothStatus.isGranted;
      nearbyPermissionEnabled = nearbyStatus.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userName = widget.plat; // Menggunakan email sebagai username
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 5,),
            SwitchListTile(
                title: const Text(
                  // 'Berikan Izin Akses',
                  'Grant Access Permissions',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 17),
                ),
                value: locationPermissionEnabled && storagePermissionEnabled && bluetoothPermissionEnabled && nearbyPermissionEnabled,
                onChanged: _togglePermissions),
            // const Text(
            //   "Periksa Izin Akses",
            // ),
            // Wrap(
            //   alignment: WrapAlignment.center,
            //   children: <Widget>[
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //         ),
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //       ),
            //       child:
            //       // Text("Periksa Izin Lokasi"),
            //       Icon(CupertinoIcons.location_solid, color: Colors.black),
            //       onPressed: () async {
            //         if (await Permission.location.isGranted) {
            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //               content: Text("Lokasi Di Izinkan:)")));
            //         } else {
            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //               content:
            //                   Text("Lokasi Tidak Di Izinkan :(")));
            //         }
            //       },
            //     ),
            //     SizedBox(width: 10,),
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //         ),
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //       ),
            //       child:
            //       // const Text("Periksa Izin Penyimpanan"),
            //       Icon(Icons.storage, color: Colors.black),
            //       onPressed: () async {
            //         if (await Permission.manageExternalStorage.isGranted) {
            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //               content:
            //               Text("Izin Penyimpanan Diberikan :)")));
            //         } else {
            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //               content: Text(
            //                   "Izin Penyimpanan Tidak Diberikan :(")));
            //         }
            //       },
            //     ),
            //     SizedBox(width: 10,),
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //         ),
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //       ),
            //       child:
            //       // const Text("periksa izin Bluetooth"),
            //       Icon(CupertinoIcons.bluetooth, color: Colors.black),
            //       onPressed: () async {
            //         if (!(await Future.wait([
            //           Permission.bluetooth.isGranted,
            //           Permission.bluetoothAdvertise.isGranted,
            //           Permission.bluetoothConnect.isGranted,
            //           Permission.bluetoothScan.isGranted,
            //         ]))
            //             .any((element) => false)) {
            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //               content: Text("Izin Bluetooth Diberikan :)")));
            //         } else {
            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //               content:
            //                   Text("Izin Bluetooth Tidak Diizinkan :(")));
            //         }
            //       },
            //     ),
            //     SizedBox(width: 10,),
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //         ),
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //       ),
            //       child:
            //       // const Text(
            //       //     "periksa Izin akses Berbagi Langsung"),
            //       Icon(Icons.near_me_outlined, color: Colors.black),
            //       onPressed: () async {
            //         if (await Permission.nearbyWifiDevices.isGranted) {
            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //               content: Text(
            //                   "Izin Berbagi Langsung Diberikan :)")));
            //         } else {
            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //               content: Text(
            //                   "Izin Berbagi Langsung Tidak Diberikan :(")));
            //         }
            //       },
            //     ),
            //   ],
            // ),
            // const Divider(color: Colors.black,),
            // const Text(
            //   "Permintaan Izin Akses",
            // ),
            // Wrap(
            //   alignment: WrapAlignment.center,
            //   children: <Widget> [
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //         ),
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //       ),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text("Permintaan Izin Lokasi",
            //             style: TextStyle(color: Colors.black),),
            //           Icon(CupertinoIcons.location_solid, color: Colors.black),
            //         ],
            //       ),
            //       onPressed: () {
            //         Permission.location.request();
            //       },
            //     ),
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //         ),
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //       ),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text("Permintaan Izin Penyimpanan",
            //             style: TextStyle(color: Colors.black),),
            //           Icon(Icons.storage, color: Colors.black),
            //         ],
            //       ),
            //       onPressed: () {
            //         Permission.storage.request();
            //         Permission.manageExternalStorage.request();
            //       },
            //     ),
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //         ),
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //       ),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text("Permintaan Izin Bluetooth",
            //             style: TextStyle(color: Colors.black),),
            //           Icon(CupertinoIcons.bluetooth, color: Colors.black),
            //         ],
            //       ),
            //       onPressed: () {
            //         [
            //           Permission.bluetooth,
            //           Permission.bluetoothAdvertise,
            //           Permission.bluetoothConnect,
            //           Permission.bluetoothScan
            //         ].request();
            //       },
            //     ),
            //     ElevatedButton(
            //       style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //         ),
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //       ),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //               "Permintaan Izin Berbagi Langsung",
            //             style: TextStyle(color: Colors.black),),
            //           Icon(Icons.near_me_outlined, color: Colors.black),
            //         ],
            //       ),
            //       onPressed: () {
            //         Permission.nearbyWifiDevices.request();
            //       },
            //     ),
            //   ],
            // ),
            const Divider(color: Colors.black,),
            Text("User Name: $userName"),
            Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        button),
                        // Color.fromRGBO(246, 233, 195, 1.0)),
                  ),
                  child: const Text(
                    // "Mulai Penyiaran",
                    'Start Advertising',
                    style: TextStyle(color: textbutton),),
                  onPressed: () async {
                    try {
                      bool a = await Nearby().startAdvertising(
                        userName,
                        strategy,
                        onConnectionInitiated: onConnectionInit,
                        onConnectionResult: (id, status) {
                          showSnackbar(status);
                        },
                        onDisconnected: (id) {
                          showSnackbar(
                              "Terputus: ${endpointMap[id]!.endpointName}, id $id");
                          setState(() {
                            endpointMap.remove(id);
                          });
                        },
                      );
                      showSnackbar("ADVERTISING: $a");
                    } catch (exception) {
                      showSnackbar(exception);
                    }
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        button),
                        // Color.fromRGBO(246, 233, 195, 1.0)),
                  ),
                  child: const Text(
                    // "Hentikan Penyiaran",
                    'Stop Advertising',
                    style: TextStyle(color: textbutton),),
                  onPressed: () async {
                    await Nearby().stopAdvertising();
                  },
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        button),
                        // Color.fromRGBO(246, 233, 195, 1.0)),
                  ),
                  child: const Text(
                    // "Mulai Pencarian",
                    'Start Discovery',
                    style: TextStyle(color: textbutton),),
                  onPressed: () async {
                    try {
                      bool a = await Nearby().startDiscovery(
                        userName,
                        strategy,
                        onEndpointFound: (id, name, serviceId) {
                          // show sheet automatically to request connection
                          showModalBottomSheet(
                            context: context,
                            builder: (builder) {
                              return Center(
                                child: Column(
                                  children: <Widget>[
                                    Text("id: $id"),
                                    Text("Name: $name"),
                                    Text("ServiceId: $serviceId"),
                                    ElevatedButton(
                                      child: const Text("Request Connection"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Nearby().requestConnection(
                                          userName,
                                          id,
                                          onConnectionInitiated: (id, info) {
                                            onConnectionInit(id, info);
                                          },
                                          onConnectionResult: (id, status) {
                                            showSnackbar(status);
                                          },
                                          onDisconnected: (id) {
                                            setState(() {
                                              endpointMap.remove(id);
                                            });
                                            showSnackbar(
                                                "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        onEndpointLost: (id) {
                          showSnackbar(
                              "Lost discovered Endpoint: ${endpointMap[id]?.endpointName}, id $id");
                        },
                      );
                      showSnackbar("DISCOVERING: $a");
                    } catch (e) {
                      showSnackbar(e);
                    }
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        button),
                        // Color.fromRGBO(246, 233, 195, 1.0)),
                  ),
                  child: const Text(
                    // "Hentikan Pencarian",
                    'Stop Discovery',
                    style: TextStyle(color: textbutton),),
                  onPressed: () async {
                    await Nearby().stopDiscovery();
                  },
                ),
              ],
            ),
            const Divider(color: Colors.black,),
            Text("Number of Connected Devices: ${endpointMap.length}"),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    button),
                    // Color.fromRGBO(246, 233, 195, 1.0)),
              ),
              child: const Text(
                // "Hentikan Koneksi",
                'Disconnect',
                style: TextStyle(color: textbutton),),
              onPressed: () async {
                await Nearby().stopAllEndpoints();
                setState(() {
                  endpointMap.clear();
                });
              },
            ),
            const Divider(color: Colors.black,),
            const Text(
              // "Kirim File",
              'Send File',
            ),
            // ElevatedButton(
            //   style: ButtonStyle(
            //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //       RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(15),
            //       ),
            //     ),
            //     backgroundColor: MaterialStateProperty.all<Color>(
            //         button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //   ),
            //   child: const Text("Tes Koneksi", style: TextStyle(color: textbutton),),
            //   onPressed: () async {
            //     endpointMap.forEach((key, value) {
            //       String a = Random().nextInt(100).toString();
            //
            //       showSnackbar("Sending $a to ${value.endpointName}, id: $key");
            //       Nearby()
            //           .sendBytesPayload(key, Uint8List.fromList(a.codeUnits));
            //     });
            //   },
            // ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  // Color.fromRGBO(246, 233, 195, 1.0)),
                    button),
              ),
              child: const Text(
                // "Kirim Data Ke Firebase",
                'Send Files to Firebase',
                style: TextStyle(color: textbutton),),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadData(plat: widget.plat),
                  ),
                );
              },
            ),
            // ElevatedButton(
            //   style: ButtonStyle(
            //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //       RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(15),
            //       ),
            //     ),
            //     backgroundColor: MaterialStateProperty.all<Color>(
            //         button),
            //         // Color.fromRGBO(246, 233, 195, 1.0)),
            //   ),
            //   child: const Text("Kirim File", style: TextStyle(color: Colors.black),),
            //   onPressed: () async {
            //     final ImagePicker _picker = ImagePicker();
            //     XFile? file = await _picker.pickImage(source: ImageSource.gallery);
            //
            //     if (file == null) return;
            //
            //     for (MapEntry<String, ConnectionInfo> m in endpointMap.entries) {
            //       int payloadId = await Nearby().sendFilePayload(m.key, file.path);
            //       showSnackbar("Sending file to ${m.key}");
            //       Nearby().sendBytesPayload(
            //         m.key,
            //         Uint8List.fromList(
            //           "$payloadId:${file.path.split('/').last}".codeUnits,
            //         ),
            //       );
            //     }
            //   },
            // ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    // Color.fromRGBO(246, 233, 195, 1.0)),
                  button),
              ),
              child: const Text(
                // "Tampilkan Lokasi File",
                'Show File Location',
                style: TextStyle(color: textbutton),),
              onPressed: () async {
                final dir = (await getExternalStorageDirectory())!;
                final files = (await dir.list(recursive: true).toList())
                    .map((f) => f.path)
                    .toList()
                    .join('\n');
                showSnackbar(files);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  Future<bool> moveFile(String uri, String fileName) async {
    String parentDir = (await getExternalStorageDirectory())!.absolute.path;
    final b =
        await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');

    showSnackbar("Moved file:$b");
    return b;
  }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text("id: $id"),
              Text("Token: ${info.authenticationToken}"),
              Text("Name${info.endpointName}"),
              Text("Incoming: ${info.isIncomingConnection}"),
              ElevatedButton(
                child: const Text("Accept Connection"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    endpointMap[id] = info;
                  });
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                      if (payload.type == PayloadType.BYTES) {
                        String str = String.fromCharCodes(payload.bytes!);
                        showSnackbar("$endid: $str");

                        if (str.contains(':')) {
                          // used for file payload as file payload is mapped as
                          // payloadId:filename
                          int payloadId = int.parse(str.split(':')[0]);
                          String fileName = (str.split(':')[1]);

                          if (map.containsKey(payloadId)) {
                            if (tempFileUri != null) {
                              moveFile(tempFileUri!, fileName);
                            } else {
                              showSnackbar("File doesn't exist");
                            }
                          } else {
                            //add to map if not already
                            map[payloadId] = fileName;
                          }
                        }
                      } else if (payload.type == PayloadType.FILE) {
                        showSnackbar("$endid: File transfer started");
                        tempFileUri = payload.uri;
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status ==
                          PayloadStatus.IN_PROGRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.FAILURE) {
                        print("failed");
                        showSnackbar("$endid: FAILED to transfer file");
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.SUCCESS) {
                        showSnackbar(
                            "$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");

                        if (map.containsKey(payloadTransferUpdate.id)) {
                          //rename the file now
                          String name = map[payloadTransferUpdate.id]!;
                          moveFile(tempFileUri!, name);
                        } else {
                          //bytes not received till yet
                          map[payloadTransferUpdate.id] = "";
                        }
                      }
                    },
                  );
                },
              ),
              ElevatedButton(
                child: const Text("Reject Connection"),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
