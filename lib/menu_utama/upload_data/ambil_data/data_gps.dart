import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';

class DataGPS extends StatefulWidget {
  @override
  final String email;

  const DataGPS({Key? key, required this.email}) : super(key: key);
  State<DataGPS> createState() => _DataGPSState();

}

class _DataGPSState extends State<DataGPS> {
  List<List<dynamic>> _csvTable = [];
  bool isLoadingUpload = false;
  late String email; // Menyimpan email dalam tipe String

  @override
  void initState() {
    super.initState();
    email = widget.email; // Inisialisasi email dari properti widget
    // _requestStoragePermission(); // Meminta izin penyimpanan saat aplikasi dimulai
  }

  // Fungsi untuk meminta izin penyimpanan
  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      print("Izin penyimpanan diberikan.");
    } else {
      print("Izin penyimpanan tidak diberikan.");
    }
  }


  Future<List<List<dynamic>>> loadCSV() async {
    // Memeriksa izin manageExternalStorage
    var manageExternalStorageStatus = await Permission.manageExternalStorage.status;
    var storageStatus = await Permission.storage.status;

    if (manageExternalStorageStatus.isGranted || storageStatus.isGranted) {
      // Izin telah diberikan, lanjutkan dengan pemilihan file CSV
      _requestStoragePermission(); // Perhatikan bahwa ini hanya dipanggil jika izin manageExternalStorage belum diberikan sebelumnya
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: true, // Memungkinkan pemilihan beberapa file
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        List<File> files = result.paths.map((path) => File(path!)).toList();
        _csvTable.clear(); // Menghapus data sebelumnya (jika ada)
        for (var file in files) {
          String csvData = await file.readAsString();
          List<List<dynamic>> table = CsvToListConverter().convert(csvData);
          _csvTable.addAll(table);
        }
        setState(() {});
      } else {
        // Batal memilih file CSV
        setState(() {
          _csvTable = [];
        });
      }
    } else {
      // Meminta izin manageExternalStorage jika belum diberikan
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        // Izin diberikan, lanjutkan dengan proses pemilihan file CSV
        return loadCSV();
      } else {
        // Meminta izin storage jika belum diberikan
        var storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          // Izin diberikan, lanjutkan dengan proses pemilihan file CSV
          return loadCSV();
        } else {
          // Izin tidak diberikan, beri tahu pengguna atau lakukan tindakan lain
          setState(() {
            _csvTable = [];
          });
        }
      }
    }
    return _csvTable;
  }

  // Fungsi untuk upload data ke Firebase
  Future<void> uploadDataToDatabase(List<List<dynamic>> data) async {
    final databaseRef = FirebaseDatabase.instance.reference();

    for (int i = 0; i < data.length; i++) {
      List<dynamic> rowData = data[i];
      String datetime = rowData[0].toString();
      double latitude = double.tryParse(rowData[1].toString()) ?? 0.0;
      double longitude = double.tryParse(rowData[2].toString()) ?? 0.0;

      //String fullDateTime = '$date, $time';

      try {
        await databaseRef.child('DataGPS').push().set({
          'datetime': datetime,
          'latitude': latitude,
          'longitude' : longitude,
          'plat' : email, //Menambahkan email ke data yang diunggah
        });
        print('$datetime, $latitude, $longitude');
        print("Data pada baris $i berhasil diupload ke database.");
      } catch (error) {
        print("Gagal mengupload data pada baris $i: $error");
      }
    }
  }

  Future<void> _handleUploadButtonPressed() async {
    if (_csvTable.isEmpty) {
      // Show a snackbar to notify the user that no data is selected for upload
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Tidak ada data GPS yang dipilih untuk diunggah."),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // Show a confirmation dialog before uploading data
    bool confirmUpload = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin mengunggah data GPS ke Firebase?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmed
            },
            child: Text('Ya'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Not confirmed
            },
            child: Text('Tidak'),
          ),
        ],
      ),
    );

    // If the user confirms the upload, proceed with uploading data to Firebase
    if (confirmUpload == true) {
      setState(() {
        isLoadingUpload = true;
      });

      List<List<dynamic>> selectedData = await loadCSV();

      if (selectedData.isNotEmpty) {
        await uploadDataToDatabase(selectedData);
      }

      setState(() {
        isLoadingUpload = false;
      });

      // Show a snackbar to notify the user that data has been uploaded
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data GPS berhasil diunggah ke Firebase."),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(234, 186, 103, 1.0),
        //backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text("Data GPS", style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open, color: Colors.black87,),
            onPressed: loadCSV,
          ),
          IconButton(
            icon: Icon(Icons.upload, color: Colors.black87,),
            onPressed: _handleUploadButtonPressed,
          ),
        ],
      ),
      body: _csvTable.isNotEmpty
          ? ListView.builder(
        itemCount: _csvTable.length,
        itemBuilder: (context, index) {
          if (_csvTable[index].length >= 3) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child:
                    Text((index + 1).toString(), style: TextStyle(color: Colors.white),),
                    backgroundColor: Color.fromRGBO(69, 69, 69, 1.0),
                  ),
                  title: Text(
                    "${_csvTable[index][0].toString()}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Latitude : ${_csvTable[index][1].toString()}"),
                      Text("Longitude : ${_csvTable[index][2].toString()}"),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      )
          : Center(
        child: Text("Data tidak ditemukan."),
      ),
    );
  }
}
