import 'dart:async';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ta_visualisasi/configure/constants.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class UploadData extends StatefulWidget {
  final String plat;

  const UploadData({Key? key, required this.plat}) : super(key: key);

  @override
  State<UploadData> createState() => _UploadDataState();
}

class _UploadDataState extends State<UploadData> {
  DatabaseReference userRef = FirebaseDatabase.instance
      .reference()
      .child('DataPerjalanan');
  List<List<dynamic>> _csvTable = [];
  bool isLoadingUpload = false;
  late String plat;

  @override
  void initState() {
    super.initState();
    plat = widget.plat;
  }

  Future<List<List<dynamic>>> loadCSV() async {
    var manageExternalStorageStatus = await Permission.manageExternalStorage.status;
    var storageStatus = await Permission.storage.status;

    if (manageExternalStorageStatus.isGranted || storageStatus.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: true,
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        _csvTable.clear();
        for (var file in files) {
          try {
            String csvData = await file.readAsString();
            List<List<dynamic>> table = CsvToListConverter(eol: '\n').convert(csvData);
            _csvTable.addAll(table);
            print("File berhasil dibaca: ${file.path}");
          } catch (e) {
            print("Error membaca file: ${file.path} dengan error: $e");
          }
        }
        setState(() {});
      } else {
        setState(() {
          _csvTable = [];
        });
      }
    } else {
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return loadCSV();
      } else {
        var storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          return loadCSV();
        } else {
          setState(() {
            _csvTable = [];
          });
        }
      }
    }
    return _csvTable;
  }

  Future<int> getCurrentJourneyNumber() async {
    DataSnapshot snapshot = await userRef.child(plat).get();
    if (snapshot.exists && snapshot.value != null) {
      Map<dynamic, dynamic> journeys = snapshot.value as Map<dynamic, dynamic>;
      List<int> journeyNumbers = journeys.keys.map((key) {
        try {
          return int.parse(key.toString().replaceAll(RegExp(r'\D'), ''));
        } catch (e) {
          return 0; // Default to 0 if parsing fails
        }
      }).toList();
      if (journeyNumbers.isNotEmpty) {
        return journeyNumbers.reduce((a, b) => a > b ? a : b);
      }
    }
    return 0;
  }

  Future<void> uploadDataToDatabase(List<List<dynamic>> data) async {
    int currentJourney = await getCurrentJourneyNumber();
    int newJourney = currentJourney + 1;
    String tanggalUpload = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()); // Get the current date and time

    DatabaseReference journeyRef = userRef.child(widget.plat).child('Data Perjalanan $newJourney');

    try {
      await journeyRef.set({
        'plat': plat,
        'Perjalanan': newJourney,
        'DateUnggah': tanggalUpload,
      });
      print("Journey number updated to $newJourney.");
    } catch (error) {
      print("Failed to update journey number: $error");
    }

    for (int i = 0; i < data.length; i++) {
      List<dynamic> rowData = data[i];
      if (rowData.length < 11) {
        print("Data tidak lengkap pada baris $i: $rowData");
        continue; // Skip this row
      }

      String datetime = rowData[0].toString();
      double distance = double.tryParse(rowData[1].toString()) ?? 0.0;
      double speed = double.tryParse(rowData[2].toString()) ?? 0.0;
      double latitude = double.tryParse(rowData[3].toString()) ?? 0.0;
      double longitude = double.tryParse(rowData[4].toString()) ?? 0.0;
      double gyro_data_x = double.tryParse(rowData[5].toString()) ?? 0.0;
      double gyro_data_y = double.tryParse(rowData[6].toString()) ?? 0.0;
      double gyro_data_z = double.tryParse(rowData[7].toString()) ?? 0.0;
      double accel_data_x = double.tryParse(rowData[8].toString()) ?? 0.0;
      double accel_data_y = double.tryParse(rowData[9].toString()) ?? 0.0;
      double accel_data_z = double.tryParse(rowData[10].toString()) ?? 0.0;

      try {
        await journeyRef.push().set({
          'datetime': datetime,
          'distance': distance,
          'speed': speed,
          'latitude': latitude,
          'longitude': longitude,
          'gyro_data_x': gyro_data_x,
          'gyro_data_y': gyro_data_y,
          'gyro_data_z': gyro_data_z,
          'accel_data_x': accel_data_x,
          'accel_data_y': accel_data_y,
          'accel_data_z': accel_data_z,
        });
        print("Data pada baris $i berhasil diupload ke database.");
      } catch (error) {
        print("Gagal mengupload data pada baris $i: $error");
      }
    }
  }

  Future<void> _handleUploadButtonPressed() async {
    if (_csvTable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Tidak ada data yang dipilih untuk diunggah."),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    List<List<dynamic>> selectedData = await loadCSV();

    if (selectedData.isNotEmpty) {
      bool confirmUpload = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin mengunggah data ke Firebase?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Ya'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Tidak'),
            ),
          ],
        ),
      );

      if (confirmUpload == true) {
        setState(() {
          isLoadingUpload = true;
        });

        await uploadDataToDatabase(selectedData);

        setState(() {
          isLoadingUpload = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Data berhasil diunggah ke Firebase."),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        iconTheme: IconThemeData(color: texticon),
        title: Text("Upload Data", style: TextStyle(color: textheader)),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open, color: texticon,),
            onPressed: loadCSV,
          ),
          IconButton(
            icon: Icon(Icons.upload, color: texticon,),
            onPressed: _handleUploadButtonPressed,
          ),
        ],
      ),
      body: _csvTable.isNotEmpty
          ? ListView.builder(
        itemCount: _csvTable.length,
        itemBuilder: (context, index) {
          if (_csvTable[index].length >= 11) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text((index + 1).toString(), style: TextStyle(color: Colors.white),),
                    backgroundColor: Color.fromRGBO(69, 69, 69, 1.0),
                  ),
                  title: Text(
                    "${_csvTable[index][0].toString()}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Distance : ${_csvTable[index][1].toString()}"),
                      Text("Speed : ${_csvTable[index][2].toString()}"),
                      Text("Latitude : ${_csvTable[index][3].toString()}"),
                      Text("Longitude : ${_csvTable[index][4].toString()}"),
                      Text("Gyro Data X : ${_csvTable[index][5].toString()}"),
                      Text("Gyro Data Y : ${_csvTable[index][6].toString()}"),
                      Text("Gyro Data Z : ${_csvTable[index][7].toString()}"),
                      Text("Accel Data X : ${_csvTable[index][8].toString()}"),
                      Text("Accel Data Y : ${_csvTable[index][9].toString()}"),
                      Text("Accel Data Z : ${_csvTable[index][10].toString()}"),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container(
              child: Text("Data tidak lengkap pada baris $index"),
            );
          }
        },
      )
          : Center(
        child: Text("Data tidak ditemukan."),
      ),
    );
  }
}
