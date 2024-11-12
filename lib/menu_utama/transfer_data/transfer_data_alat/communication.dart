import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Communication {
  late BluetoothConnection? connection;
  String result = '';

  Future<void> connectBl(String address) async {
    try {
      connection = await BluetoothConnection.toAddress(address);
      print('Connected to the device');

      if (connection != null && connection!.input != null) {
        connection!.input!.listen(onDataReceived).onDone(() {});
      }
    } catch (error) {
      print('Cannot connect, exception occurred');
    }
  }

  void onDataReceived(Uint8List data) {
    result = utf8.decode(data);
  }

  Future<void> sendMessage(String text) async {
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;
      } catch (e) {}
    }
  }

  Future<void> dispose() async {
    if (connection != null && connection!.isConnected) {
      connection!.dispose();
      connection = null;
    }
  }
}
