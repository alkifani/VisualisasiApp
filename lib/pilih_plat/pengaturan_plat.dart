import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/pilih_plat/pilih_plat.dart';
import 'package:flutter/cupertino.dart';

FirebaseAuth auth = FirebaseAuth.instance;
class AddDataPlat extends StatefulWidget {
  const AddDataPlat({Key? key, required this.email}) : super(key: key);
  final String email;
  @override
  _AddDataPlatState createState() => _AddDataPlatState();
}

class _AddDataPlatState extends State<AddDataPlat> {
  // final databaseRef = FirebaseDatabase.instance.reference().child("DataKendaraan");
  // Set the reference to the correct location under the user's DataKendaraan node
  DatabaseReference userRef = FirebaseDatabase.instance.reference().child("users").child(auth.currentUser!.uid).child("DataKendaraan");
  DatabaseReference perjalananRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");
  final TextEditingController jenisController = TextEditingController();
  final TextEditingController noMesinController = TextEditingController();
  final TextEditingController noKerangkaController = TextEditingController();
  final TextEditingController platController = TextEditingController();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  void fetchDataFromFirebase() {
    // databaseRef.orderByChild('email').equalTo(widget.email).onValue.listen((event) {
    userRef.orderByChild('email').equalTo(widget.email).onValue.listen((event) {
      // databaseRef.onValue.listen((event) {
      final DataSnapshot? snapshot = event.snapshot;
      if (snapshot != null && snapshot.value is Map<dynamic, dynamic>) {
        final Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        print("Fetched data from Firebase: $values");
        // Handle Firebase data here
      }
    }, onError: (error) {
      print("Error fetching data from Firebase: $error");
    });
  }

  void removePerjalananByPlat(String plathapus) async {
    try {
      await perjalananRef.child(plathapus).remove();
      print("Data successfully removed.");
      _showDeleteSuccessNotification();
    } catch (error) {
      print("Error removing data: $error");
      // _showErrorNotification();
    }
  }

  void removeData(String key) {
    userRef.child(key).remove().then((_) {
      print("Data successfully removed.");
      // _showDeleteSuccessNotification();
      // removePerjalananByPlat(plat); // Hapus data perjalanan berdasarkan Plat
    }).catchError((error) {
      print("Error removing data: $error");
      // _showErrorNotification();
    });
  }

  Future<void> _showDeletedDialog(String key, String plathapus) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('data dari mna $key $plathapus');
                removeData(key);
                removePerjalananByPlat(plathapus);
                Navigator.of(context).pop();

                // Navigasi kembali ke halaman sebelumnya
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DataPlat(email: widget.email),
                  ),
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to add this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
                addData();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }


  Future<bool> checkDuplicateData(String plat, String noMesin, String noKerangka) async {
    // Lakukan pencarian di Firebase untuk memeriksa apakah data duplikat
    // DatabaseReference checkdouble = FirebaseDatabase.instance.reference().child("users").child(auth.currentUser!.uid).child("DataKendaraan");
    DatabaseReference checkdouble = FirebaseDatabase.instance.reference().child("users").child(auth.currentUser!.uid).child("DataKendaraan");
    DataSnapshot dataSnapshot = await checkdouble.get();

    // Periksa apakah snapshot memiliki nilai yang tidak null dan tipe yang sesuai
    if (dataSnapshot.value != null && dataSnapshot.value is Map<dynamic, dynamic>) {
      // Konversi nilai snapshot menjadi tipe Map<dynamic, dynamic>
      Map<dynamic, dynamic> dataMap = dataSnapshot.value as Map<dynamic, dynamic>;

      // Lakukan iterasi pada setiap entri 'DataKendaraan'
      for (var entry in dataMap.entries) {
        // Ambil nilai dari setiap entri dan cek jika nilainya adalah Map
        if (entry.value is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> data = entry.value as Map<dynamic, dynamic>;

          // Bandingkan dengan data yang baru
          if (data["Plat"] == plat || data["NoMesin"] == noMesin || data["NoKerangka"] == noKerangka) {
            // Data dengan nomor plat, nomor mesin, atau nomor kerangka yang sama ditemukan, return true
            return true;
          }
        }
      }
    }

    // Tidak ada data duplikat ditemukan, return false
    return false;
  }


  Future<void> addData() async {
    print('Adding data...');
    final jenisKendaraan = jenisController.text.toUpperCase();
    final noMesin = noMesinController.text.toUpperCase();
    final noKerangka = noKerangkaController.text.toUpperCase();
    final plat = platController.text.toUpperCase();

    if (jenisKendaraan.isNotEmpty && noMesin.isNotEmpty && noKerangka.isNotEmpty && plat.isNotEmpty) {
      // Tidak ada kesalahan, data diisi dengan benar
      setState(() {
        errorMessage = '';
      });

      // Check if the Plat value already exists in Firebase
      // DatabaseEvent event = await databaseRef.orderByChild('Plat').equalTo(plat).once();
      // DataSnapshot snapshot = event.snapshot;

      // if (snapshot.value != null) {
      //   // Plat value already exists, show an error message
      //   setState(() {
      //     errorMessage = 'Plat sudah ada di dalam database.';
      //     // ScaffoldMessenger.of(context).showSnackBar(
      //     //   SnackBar(
      //     //     content: Text('Plat sudah ada di dalam database.'),
      //     //     backgroundColor: Colors.grey,
      //     //   ),
      //     // );
      //   });

      // Pemeriksaan apakah nomor plat, nomor mesin, dan nomor kerangka sudah ada di Firebase
      bool isDuplicate = await checkDuplicateData(plat, noMesin, noKerangka);

      if (isDuplicate) {
        // Tampilkan pesan kesalahan jika data duplikat ditemukan
        setState(() {
          errorMessage = 'Data with the same license plate, engine number, or Vehicle Identification Number already exists';
        });
      } else {
        // Plat value doesn't exist, proceed to add the data
        await userRef.push().set({
          'email': widget.email,
          'JenisKendaraan': jenisKendaraan,
          'NoMesin': noMesin,
          'NoKerangka': noKerangka,
          'Plat': plat,
        }).then((_) {
          // Data berhasil terkirim, tampilkan pemberitahuan sukses
          _showSuccessNotification();

          // Tutup dialog konfirmasi
          Navigator.of(context).pop();

          // Navigasi kembali ke halaman sebelumnya
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DataPlat(email: widget.email),
            ),
          );
        }).catchError((error) {
          print("Error sending data to Firebase: $error");
          _showErrorNotification();
        });
      }
    } else {
      setState(() {
        errorMessage = 'All data must be filled out';
      });
    }
  }


  void _showSuccessNotification() {
    // Tampilkan pemberitahuan bahwa data berhasil terkirim
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data successfully saved'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _showDeleteSuccessNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('License Plate and Trip Data Successfully Deleted'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _showErrorNotification() {
    // Tampilkan pemberitahuan jika terjadi kesalahan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An Error Occurred While Sending Data'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        iconTheme: const IconThemeData(color: leadingcolor),
        // backgroundColor: Color.fromRGBO(234, 186, 103, 1.0),
        title: Text('Vehicle Data Setup',style: TextStyle(color: textheader),),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.93,
                //height: MediaQuery.of(context).size.height * 0.5, // Mengatur tinggi kontainer menjadi setengah dari tinggi layar
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Add Vehicle Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: jenisController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0), // Set the border radius to 20
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0), // Sudut border
                                ),
                              ),
                              labelText: 'Vehicle Type'
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: noMesinController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0), // Set the border radius to 20
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0), // Sudut border
                              ),
                            ),
                            labelText: 'Engine Number',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: noKerangkaController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0), // Set the border radius to 20
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0), // Sudut border
                              ),
                            ),
                            labelText: 'Vehicle Identification Number',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: platController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0), // Set the border radius to 20
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black), // Warna garis saat difokuskan
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0), // Sudut border
                                ),
                              ),
                              labelText: 'License Plate'
                          ),
                        ),
                      ),
                      // SizedBox(height: 8.0),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog();
                          },
                          // onPressed: (addData),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                button
                              //Color.fromRGBO(69, 69, 69, 1.0)
                            ),
                          ),
                          child: Text('Add Data', style: TextStyle(color: textbutton),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.93,
                height: MediaQuery.of(context).size.height * 0.36, // Mengatur tinggi kontainer menjadi setengah dari tinggi layar
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Delete Vehicle Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child:
                        StreamBuilder(
                          // stream: databaseRef.orderByChild('email').equalTo(widget.email).onValue,
                          // stream: databaseRef.onValue,
                          stream: userRef.orderByChild('email').equalTo(widget.email).onValue,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              final DataSnapshot? dataSnapshot = snapshot.data?.snapshot;
                              final dynamic values = dataSnapshot?.value;

                              if (values is Map<dynamic, dynamic>) {
                                final dataKeys = values.keys.toList();

                                // if (dataKeys.isEmpty) {
                                //   // Tampilkan pesan jika tidak ada data
                                //   return Center(
                                //     child: Text('Tidak ada data tersedia.'),
                                //   );
                                // }
                                if (!snapshot.hasData) {
                                  // Tampilkan widget untuk menunjukkan bahwa data sedang dimuat
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (dataKeys.isEmpty) {
                                  // Tampilkan pesan jika tidak ada data
                                  return Center(
                                    child: Text('Tidak ada data tersedia.'),
                                  );
                                }


                                return ListView.builder(
                                  itemCount: dataKeys.length,
                                  itemBuilder: (context, index) {
                                    final key = dataKeys[index];
                                    final data = values[key] as Map<dynamic, dynamic>;
                                    print("data dari key$key dan $data");

                                    return Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Card(
                                        elevation: 2,
                                        child: ListTile(
                                          title: Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/plat2.svg', // Ganti dengan path ke file SVG Anda
                                                width: 25,
                                                height: 25,
                                                color: Colors.black,
                                              ),
                                              SizedBox(width: 5,),
                                              Text(data['Plat'] ?? ''),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            // mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(CupertinoIcons.car_detailed, color: Colors.black,),
                                                  SizedBox(width: 5,),
                                                  Text(data['JenisKendaraan'] ?? ''),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(CupertinoIcons.gear, color: Colors.black,),
                                                  SizedBox(width: 5,),
                                                  Text(data['NoMesin'] ?? ''),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/kerangkamobil.svg', // Ganti dengan path ke file SVG Anda
                                                    width: 25,
                                                    height: 25,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Text(data['NoKerangka'] ?? ''),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // leading: Text(data['NoMesin'] ?? ''),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              final plathapus = data['Plat'] ?? '';
                                              print('mendapatkan data hapus $plathapus');
                                              _showDeletedDialog(key, plathapus);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }

                            return Center(
                              // child: CircularProgressIndicator(),
                              child: Text('Tidak ada data tersedia.'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
