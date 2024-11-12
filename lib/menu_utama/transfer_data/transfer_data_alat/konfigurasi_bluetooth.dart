// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/transfer_data/transfer_data_alat/communication.dart';
import 'package:ta_visualisasi/menu_utama/upload_data/upload_data.dart';

import './SelectBondedDevicePage.dart';
import 'chatpage.dart';

class KonfigurasiBluetooth extends StatefulWidget {
  static const routeName = "/KonfigurasiBluetooth";
  final String plat;

  const KonfigurasiBluetooth({Key? key, required this.plat}) : super(key: key);

  @override
  State<KonfigurasiBluetooth> createState() => _KonfigurasiBluetoothState();
}

class _KonfigurasiBluetoothState extends State<KonfigurasiBluetooth> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  String _address = "...";
  String _name = "...";

  bool _bluetoothPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() async {
    await _requestBluetoothPermission();
    _getBluetoothState();
    _getAddress();
    _getName();
    _listenBluetoothState();
  }

  Future<void> _requestBluetoothPermission() async {
    final permissionStatus = await Permission.bluetooth.request();

    if (permissionStatus.isGranted) {
      setState(() {
        _bluetoothPermissionGranted = true;
      });
    } else {
      setState(() {
        _bluetoothPermissionGranted = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Izin Dibutuhkan'),
          content: const Text('Aplikasi membutuhkan izin untuk menggunakan Bluetooth.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  void _getBluetoothState() async {
    BluetoothState state = await FlutterBluetoothSerial.instance.state;
    setState(() {
      _bluetoothState = state;
    });
  }

  void _getAddress() async {
    String? address = await FlutterBluetoothSerial.instance.address;
    setState(() {
      _address = address!;
    });
  }

  void _getName() async {
    try {
      String? name = await FlutterBluetoothSerial.instance.name;
      if (name != null) {
        setState(() {
          _name = name;
        });
      }
    } catch (e) {
      print('Error fetching name: $e');
    }
  }

  void _listenBluetoothState() {
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  void _initCommunication() async {
    Communication com = Communication();
    await com.connectBl(_address);
    com.sendMessage("Hello");
    setState(() {});
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        title: const Text(
          'Koneksi Bluetooth',
          style: TextStyle(
            color: textheader,
          ),
        ),
        iconTheme: const IconThemeData(
          color: textheader,
          //size: 30,
        ),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            SwitchListTile(
              title: const Text(
                'Hidupkan Bluetooth',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) async {
                if (value) {
                  await _enableBluetooth();
                } else {
                  await _disableBluetooth();
                }
              },
            ),
            ListTile(
              title: const Text(
                'Status Bluetooth',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              subtitle: Text(
                _bluetoothState.toString(),
                style: const TextStyle(color: Colors.black87),
              ),
              trailing: ElevatedButton(
                child: const Text(
                  'Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(69, 69, 69, 1.0),
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Nama Perangkat',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              subtitle: Text(
                _name,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            ListTile(
              title: const Text(
                'Alamat Perangkat',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              subtitle: Text(
                _address,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(
              height: 55,
            ),
            SizedBox(
              height: 61,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 6),
                child: ElevatedButton(
                  onPressed: () async {
                    _startDeviceSelection();
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(69, 69, 69, 1.0),
                    ),
                  ),
                  child: const Text(
                    'SANDINGKAN BLUETOOTH DENGAN ALAT',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if (!_bluetoothPermissionGranted)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Anda perlu memberikan izin untuk menggunakan Bluetooth.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _enableBluetooth() async {
    try {
      await FlutterBluetoothSerial.instance.requestEnable();
    } catch (e) {
      print('Error enabling Bluetooth: $e');
      _showErrorDialog('Gagal Mengaktifkan Bluetooth');
    }
    setState(() {});
  }

  Future<void> _disableBluetooth() async {
    try {
      await FlutterBluetoothSerial.instance.requestDisable();
    } catch (e) {
      print('Error disabling Bluetooth: $e');
      _showErrorDialog('Gagal Menonaktifkan Bluetooth');
    }
    setState(() {});
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _startDeviceSelection() async {
    try {
      final BluetoothDevice? selectedDevice = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return SelectBondedDevicePage(checkAvailability: false);
          },
        ),
      );

      if (selectedDevice != null) {
        print('Connect -> selected ' + selectedDevice.address);
        _startChat(context, selectedDevice);
      } else {
        print('Connect -> no device selected');
      }
    } catch (error) {
      print('Error selecting device: $error');
    }
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return UploadData(plat: widget.plat);
            // ChatPage(
            // server: server,
            // email: widget.email,
            // );
        },
      ),
    );
  }
}
