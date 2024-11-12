// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ta_visualisasi/menu_utama/upload_data/upload_data.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;
  final String email;

  const ChatPage({required this.server, required this.email});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  String senderEmail;
  String text;

  _Message(this.senderEmail, this.text);
}

class _ChatPage extends State<ChatPage> {
  String? mulaiValue;
  bool? isSendingLocation;

  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = <_Message>[];
  String _messageBuffer = '';
  Timer? locationTimer;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;

  bool get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection?.input?.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = _buildMessageList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black87, size: 30,),
        //   onPressed: () {
        //     Navigator.of(context).pushAndRemoveUntil(
        //       MaterialPageRoute(builder: (context) => MenuAutentikasi(email: widget.email)),
        //           (Route<dynamic> route) => false,
        //     );
        //   },
        // ),
        title: Text(
          isConnecting
              ? 'Connecting chat to ${widget.server.name}...'
              : isConnected
              ? 'Live chat with ${widget.server.name}'
              : 'Chat log with ${widget.server.name}',
          style: TextStyle(color: Colors.black87),
        ),
        // backgroundColor: Color.fromRGBO(0, 28, 48, 0.5),
      ),
      // backgroundColor: Color.fromRGBO(23, 107, 135, 1),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: ElevatedButton(
                  onPressed: isConnected
                      ? () => _sendMessage("Mulai")
                      : null, child: Text("Rekam Data")
              ),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    _sendMessage("Berhenti");
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => UploadData(plat: widget.email)),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: Text("Upload Data")
              ),
            ),
            Center(
              child: TextField(
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: isConnecting
                      ? 'Wait until connected...'
                      : isConnected
                      ? 'Hubungkan atau Putuskan Koneksi'
                      : 'Chat got disconnected',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                enabled: isConnected,
              ),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     padding: EdgeInsets.all(8.0),
            //     itemBuilder: (_, int index) => list[index],
            //     itemCount: list.length,
            //     reverse: true,
            //     controller: listScrollController,
            //   ),
            // ),
            //SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMessageList() {
    return messages.reversed.map((message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              '${message.senderEmail}: ${message.text.trim()}',
              style: TextStyle(color: Colors.white),
            ),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
              color: message.senderEmail == widget.email
                  ? Colors.blueAccent
                  : Colors.grey,
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
        ],
        mainAxisAlignment: message.senderEmail == widget.email
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();
  }

  void _onDataReceived(Uint8List data) {
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        String email = '';
        String text = '';
        final parts = dataString.split(':');
        if (parts.length == 2) {
          email = parts[0];
          text = parts[1];
        } else {
          text = dataString.substring(0, index);
        }

        messages.add(_Message(email, text));
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.isNotEmpty) {
      try {
        final message = '${widget.email}:$text'; // Menyertakan email pengirim pesan
        connection?.output.add(Uint8List.fromList(utf8.encode(message + '\r\n')));
        await connection?.output.allSent;

        setState(() {
          messages.add(_Message(widget.email, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
            listScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 333),
            curve: Curves.easeOut,
          );
        });
      } catch (e) {
        setState(() {});
      }
    }
  }
}
