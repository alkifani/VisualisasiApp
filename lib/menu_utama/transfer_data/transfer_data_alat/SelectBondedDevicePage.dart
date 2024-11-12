import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:ta_visualisasi/configure/constants.dart';

import './BluetoothDeviceListEntry.dart';

class SelectBondedDevicePage extends StatefulWidget {
  final bool checkAvailability;

  const SelectBondedDevicePage({this.checkAvailability = true});

  @override
  _SelectBondedDevicePageState createState() => _SelectBondedDevicePageState();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi = 0]);
}

class _SelectBondedDevicePageState extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices = <_DeviceWithAvailability>[];
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map((device) => _DeviceWithAvailability(
          device,
          widget.checkAvailability ? _DeviceAvailability.maybe : _DeviceAvailability.yes,
        ))
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    try {
      _discoveryStreamSubscription = FlutterBluetoothSerial.instance
          .startDiscovery()
          .listen(
            (r) {
          setState(() {
            devices = devices.map((_device) {
              if (_device.device == r.device) {
                return _DeviceWithAvailability(
                  r.device,
                  _DeviceAvailability.yes,
                  r.rssi ?? 0,
                );
              }
              return _device;
            }).toList();
          });
        },
        onDone: () {
          setState(() {
            _isDiscovering = false;
          });
        },
        onError: (error) {
          print('Discovery error: $error');
          setState(() {
            _isDiscovering = false;
          });
        },
      );
    } catch (error) {
      print('Failed to start discovery: $error');
      setState(() {
        _isDiscovering = false;
      });
    }
  }

  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map((_device) => BluetoothDeviceListEntry(
      key: ValueKey(_device.device.address),
      device: _device.device,
      rssi: _device.rssi,
      isEnabled: _device.availability == _DeviceAvailability.yes,
      onTap: () {
        Navigator.of(context).pop(_device.device);
      },
      onLongPress: () {},
    ))
        .toList();
    return Scaffold(
      //backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        title: const Text(
          'Pilih Perangkat',
          style: TextStyle(color: textheader),
        ),
        iconTheme: IconThemeData(
          color: textheader,
          //size: 30,
        ),
        actions: <Widget>[
          _isDiscovering
              ? FittedBox(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  textheader,
                ),
              ),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.replay, color: textheader),
            onPressed: _restartDiscovery,
          ),
        ],
      ),
      body: ListView(children: list),
    );
  }
}
