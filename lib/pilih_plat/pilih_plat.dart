import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/home_bottom.dart';
import 'package:ta_visualisasi/pilih_plat/pengaturan_plat.dart';
import 'package:flutter/cupertino.dart';

// final databaseRef = FirebaseDatabase.instance.reference().child("DataKendaraan");
FirebaseAuth auth = FirebaseAuth.instance;

class DataPlat extends StatefulWidget {
  // const DataPlat({Key? key});
  const DataPlat({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<DataPlat> createState() => _DataPlatState();
}

class _DataPlatState extends State<DataPlat> {
  DatabaseReference userRef = FirebaseDatabase.instance
      .reference()
      .child("users")
      .child(auth.currentUser!.uid)
      .child("DataKendaraan");
  List<String> kendaraanPlat = [];
  Map<String, dynamic> selectedData = {}; // Menyimpan data kendaraan yang dipilih
  Map<String, String> lastUploadDates = {};

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  void fetchDataFromFirebase() {
    userRef.orderByChild('email').equalTo(widget.email).onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        final Map<dynamic, dynamic> values =
        snapshot.value as Map<dynamic, dynamic>;
        kendaraanPlat.clear(); // Membersihkan daftar sebelum menambahkan data yang baru
        values.forEach((key, value) {
          final plat = value["Plat"] as String?;
          if (plat != null) {
            kendaraanPlat.add(plat);
          }
        });
        sortPlatesAlphabetically();
        setState(() {});
        fetchLastUploadDate(); // Panggil fungsi fetchLastUploadDate setelah data kendaraan diambil
      }
    }, onError: (error) {
      print("Error fetching data from Firebase: $error");
    });
  }

  void fetchLastUploadDate() {
    for (final plat in kendaraanPlat) {
      final perjalananRef = FirebaseDatabase.instance
          .reference()
          .child("DataPerjalanan")
          .child(plat);

      perjalananRef.orderByKey().limitToLast(1).onValue.listen((event) {
        final DataSnapshot snapshot = event.snapshot;
        final dynamic lastEntry = snapshot.value;
        if (lastEntry != null && lastEntry is Map<dynamic, dynamic>) {
          final lastEntryKey = lastEntry.keys.first;
          final lastDataPerjalanan = lastEntry[lastEntryKey];
          if (lastDataPerjalanan != null &&
              lastDataPerjalanan is Map<dynamic, dynamic>) {
            final lastUploadDate = lastDataPerjalanan["DateUnggah"];
            setState(() {
              lastUploadDates[plat] = lastUploadDate;
            });
          }
        }
      });
    }
  }

  void sortPlatesAlphabetically() {
    kendaraanPlat.sort((a, b) {
      // Jika keduanya merupakan angka, urutkan berdasarkan angka
      if (int.tryParse(a) != null && int.tryParse(b) != null) {
        return int.parse(a).compareTo(int.parse(b));
      }
      // Jika keduanya bukan angka, urutkan berdasarkan abjad
      else {
        return a.compareTo(b);
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        elevation: 0,
        iconTheme: IconThemeData(color: leadingcolor),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Vehicle List", style: TextStyle(color: textheader)),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddDataPlat(email: widget.email),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.gear_big, color: texticon),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              // Text(
              //   'Silahkan Pilih Plat Kendaraan Anda!',
              //   style: TextStyle(
              //       fontWeight: FontWeight.bold, color: Colors.black),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 1,
                  height: MediaQuery.of(context).size.height / 1.8,
                  child: Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: kendaraanPlat.length,
                      itemBuilder: (BuildContext context, int index) {
                        final plat = kendaraanPlat[index];
                        final lastUploadDate = lastUploadDates[plat] ?? "N/A";
                        return ListTile(
                          leading: SvgPicture.asset(
                            'assets/icons/plat2.svg', // Ganti dengan path ke file SVG Anda
                            width: 30,
                            height: 30,
                            color: Colors.black,
                          ),
                          title: Text(plat),
                          subtitle: Text("Last Upload Data: $lastUploadDate"),
                          onTap: () {
                            setState(() {
                              selectedValue = plat;
                              selectedData = {};
                              userRef
                                  .orderByChild("Plat")
                                  .equalTo(selectedValue)
                                  .onValue
                                  .listen((event) {
                                final DataSnapshot snapshot = event.snapshot;
                                final dynamic snapshotValue = snapshot.value;
                                if (snapshotValue != null &&
                                    snapshotValue is Map<dynamic, dynamic>) {
                                  selectedData =
                                  Map<String, dynamic>.from(snapshotValue);
                                  print(selectedValue);
                                  print('select data $selectedData');
                                } else {
                                  print("Invalid data received from Firebase.");
                                }
                                setState(() {});
                              });
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              selectedData.isNotEmpty
                  ? Column(
                children: selectedData.entries.map((entry) {
                  final data = entry.value;
                  return Card(
                    elevation: 2,
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(CupertinoIcons.car_detailed),
                                SizedBox(width: 10),
                                Text(
                                  "${data['JenisKendaraan']}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(CupertinoIcons.gear),
                                SizedBox(width: 10),
                                Text("${data['NoMesin']}"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/kerangkamobil.svg',
                                  width: 25,
                                  height: 25,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text("${data['NoKerangka']}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width / 2.25,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedValue != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HomeBottom(
                            plat: selectedValue!,
                          ),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(button),
                  ),
                  child: Text(
                    'Select Vehicle',
                    style: TextStyle(color: textbutton),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:ta_visualisasi/configure/constants.dart';
// import 'package:ta_visualisasi/menu_utama/home_bottom.dart';
// import 'package:ta_visualisasi/pilih_plat/pengaturan_plat.dart';
// import 'package:flutter/cupertino.dart';
//
// // final databaseRef = FirebaseDatabase.instance.reference().child("DataKendaraan");
// FirebaseAuth auth = FirebaseAuth.instance;
// class DataPlat extends StatefulWidget {
//   // const DataPlat({Key? key});
//   const DataPlat({Key? key, required this.email}) : super(key: key);
//   final String email;
//
//   @override
//   State<DataPlat> createState() => _DataPlatState();
// }
//
// class _DataPlatState extends State<DataPlat> {
//   DatabaseReference userRef = FirebaseDatabase.instance.reference().child("users").child(auth.currentUser!.uid).child("DataKendaraan");
//   List<String> kendaraanPlat = [];
//   Map<String, dynamic> selectedData = {}; // Menyimpan data kendaraan yang dipilih
//
//   String? selectedValue;
//   final TextEditingController textEditingController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDataFromFirebase();
//   }
//
//   void fetchDataFromFirebase() {
//     userRef.orderByChild('email').equalTo(widget.email).onValue.listen((event) {
//     // databaseRef.orderByChild('email').equalTo(widget.email).onValue.listen((event) {
//     // databaseRef.onValue.listen((event) {
//       final DataSnapshot snapshot = event.snapshot;
//       if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
//         final Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
//         kendaraanPlat.clear(); // Membersihkan daftar sebelum menambahkan data yang baru
//         values.forEach((key, value) {
//           // final plat = value[widget.email] as String?;
//           final plat = value["Plat"] as String?;
//           if (plat != null) {
//             kendaraanPlat.add(plat);
//           }
//           print("isi data kendaraan: $kendaraanPlat");
//         });
//         sortPlatesAlphabetically();
//         setState(() {});
//       }
//     }, onError: (error) {
//       print("Error fetching data from Firebase: $error");
//     });
//   }
//
//   void sortPlatesAlphabetically() {
//     kendaraanPlat.sort((a, b) {
//       // Jika keduanya merupakan angka, urutkan berdasarkan angka
//       if (int.tryParse(a) != null && int.tryParse(b) != null) {
//         return int.parse(a).compareTo(int.parse(b));
//       }
//       // Jika keduanya bukan angka, urutkan berdasarkan abjad
//       else {
//         return a.compareTo(b);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     textEditingController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: header,
//         // backgroundColor: Color.fromRGBO(234, 186, 103, 1.0),
//         elevation: 0,
//         iconTheme: IconThemeData(color: leadingcolor),
//         centerTitle: true,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text("Pilih Kendaraan", style: TextStyle(color: textheader)),
//             IconButton(onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => AddDataPlat(email: widget.email),
//                 ),
//               );
//             },
//                 icon: Icon(CupertinoIcons.gear_big, color: texticon,))
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             children: [
//               SizedBox(height: 30,),
//               // Padding(
//               //   padding: const EdgeInsets.all(8.0),
//               //   child: ElevatedButton(
//               //     onPressed: () {
//               //       Navigator.of(context).push(
//               //         MaterialPageRoute(
//               //           builder: (context) => AddDataPlat(email: widget.email),
//               //         ),
//               //       );
//               //     },
//               //     style: ButtonStyle(
//               //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//               //         RoundedRectangleBorder(
//               //           borderRadius: BorderRadius.circular(15),
//               //         ),
//               //       ),
//               //       backgroundColor: MaterialStateProperty.all<Color>(
//               //           button
//               //       ),
//               //     ),
//               //     child:
//               //     Text('Pengaturan Data Kendaraan', style: TextStyle(color: Colors.black),),
//               //   ),
//               // ),
//               // const SizedBox(
//               //   height: 20,
//               // ),
//               Text('Silahkan Pilih Plat Kendaraan Anda!', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
//               SizedBox(
//                 height: 10,
//               ),
//               // DropdownButtonHideUnderline(
//               //   child: DropdownButton2<String>(
//               //     isExpanded: false,
//               //     hint: Row(
//               //       mainAxisAlignment: MainAxisAlignment.center,
//               //       children: [
//               //         Icon(
//               //           Icons.search, // Ganti dengan ikon pencarian yang diinginkan
//               //           size: 20,
//               //           color: textbutton,
//               //           // color: Theme.of(context).hintColor,
//               //         ),
//               //         SizedBox(width: 8), // Jarak antara ikon dan teks
//               //         Text(
//               //           'Cari plat Disini',
//               //           style: TextStyle(
//               //             fontSize: 14,
//               //             color: textbutton
//               //             // color: Theme.of(context).hintColor,
//               //           ),
//               //           textAlign: TextAlign.center,
//               //         ),
//               //       ],
//               //     ),
//               //     items: kendaraanPlat
//               //         .map((item) => DropdownMenuItem<String>(
//               //       value: item,
//               //       child: Text(
//               //         item,
//               //         style: const TextStyle(
//               //           fontSize: 14,
//               //
//               //         ),
//               //       ),
//               //     ))
//               //         .toList(),
//               //     value: selectedValue,
//               //     onChanged: (value) {
//               //       setState(() {
//               //         selectedValue = value;
//               //         // Saat item dipilih, data akan diperbarui secara real-time.
//               //         selectedData = {}; // Kosongkan data terlebih dahulu
//               //         databaseRef
//               //             .orderByChild("Plat")
//               //             .equalTo(selectedValue)
//               //             .onValue
//               //             .listen((event) {
//               //           final DataSnapshot snapshot = event.snapshot;
//               //           final dynamic snapshotValue = snapshot.value;
//               //           if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
//               //             selectedData = Map<String, dynamic>.from(snapshotValue);
//               //             print(selectedValue);
//               //             print('select data $selectedData');
//               //           } else {
//               //             // Tangani kesalahan jika tipe data tidak sesuai
//               //             print("Invalid data received from Firebase.");
//               //           }
//               //           setState(() {});
//               //         });
//               //       });
//               //     },
//               //     buttonStyleData: const ButtonStyleData(
//               //       padding: EdgeInsets.symmetric(horizontal: 16),
//               //       height: 50,
//               //       width: 300,
//               //       decoration: BoxDecoration(
//               //         color: button,
//               //         borderRadius: BorderRadius.all(Radius.circular(10))
//               //       )
//               //       // height: 40,
//               //       // width: 200,
//               //     ),
//               //     dropdownStyleData: const DropdownStyleData(
//               //       maxHeight: 200,
//               //     ),
//               //     menuItemStyleData: const MenuItemStyleData(
//               //       height: 40,
//               //     ),
//               //     dropdownSearchData: DropdownSearchData(
//               //       searchController: textEditingController,
//               //       searchInnerWidgetHeight: 50,
//               //       searchInnerWidget: Container(
//               //         height: 50,
//               //         padding: const EdgeInsets.only(
//               //           top: 8,
//               //           bottom: 4,
//               //           right: 8,
//               //           left: 8,
//               //         ),
//               //         child: TextFormField(
//               //           expands: true,
//               //           maxLines: null,
//               //           controller: textEditingController,
//               //           decoration: InputDecoration(
//               //             isDense: true,
//               //             contentPadding: const EdgeInsets.symmetric(
//               //               horizontal: 10,
//               //               vertical: 8,
//               //             ),
//               //             hintText: 'Search for an item...',
//               //             hintStyle: const TextStyle(fontSize: 12),
//               //             border: OutlineInputBorder(
//               //               borderRadius: BorderRadius.circular(10),
//               //             ),
//               //           ),
//               //         ),
//               //       ),
//               //     ),
//               //     //This to clear the search value when you close the menu
//               //     onMenuStateChange: (isOpen) {
//               //       if (!isOpen) {
//               //         textEditingController.clear();
//               //       }
//               //     },
//               //   ),
//               // ),
//               // SizedBox(height: 5,),
//               // Menambahkan daftar nomor plat di bawah dropdown
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   width: MediaQuery.of(context).size.width / 1,
//                   // height: MediaQuery.of(context).size.height / 2.25,
//                   height: MediaQuery.of(context).size.height / 3,
//                   child: Card(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: kendaraanPlat.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         final plat = kendaraanPlat[index];
//                         return ListTile(
//                           leading: SvgPicture.asset(
//                             'assets/icons/plat2.svg', // Ganti dengan path ke file SVG Anda
//                             width: 25,
//                             height: 25,
//                             color: Colors.black,
//                           ),
//                           title: Text(plat),
//                           onTap: () {
//                             setState(() {
//                               selectedValue = plat;
//                               // Saat item dipilih, data akan diperbarui secara real-time.
//                               selectedData = {}; // Kosongkan data terlebih dahulu
//                               // databaseRef
//                               //     .orderByChild("Plat")
//                               //     .equalTo(selectedValue)
//                               //     .onValue
//                               //     .listen((event) {
//                               userRef
//                                   .orderByChild("Plat")
//                                   .equalTo(selectedValue)
//                                   .onValue
//                                   .listen((event) {
//                                 final DataSnapshot snapshot = event.snapshot;
//                                 final dynamic snapshotValue = snapshot.value;
//                                 if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
//                                   selectedData = Map<String, dynamic>.from(snapshotValue);
//                                   print(selectedValue);
//                                   print('select data $selectedData');
//                                 } else {
//                                   // Tangani kesalahan jika tipe data tidak sesuai
//                                   print("Invalid data received from Firebase.");
//                                 }
//                                 setState(() {});
//                               });
//                             });
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               // Menampilkan data kendaraan yang dipilih di sini
//               selectedData.isNotEmpty
//                   ? Column(
//                 children: selectedData.entries.map((entry) {
//                   final data = entry.value;
//                   return Card(
//                     elevation: 2,
//                     child: Container(
//                       alignment: Alignment.center,
//                       width: MediaQuery.of(context).size.width * 0.5,
//                       //height: MediaQuery.of(context).size.height * 0.5,
//                       child: Padding(
//                         padding: const EdgeInsets.all(5.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           //crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               // crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 // SizedBox(width: 20,),
//                                 Icon(CupertinoIcons.car_detailed),
//                                 SizedBox(width: 10,),
//                                 Text(
//                                   // "Jenis Kendaraan: ${data['JenisKendaraan']}",
//                                   "${data['JenisKendaraan']}",
//                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               // crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 // SizedBox(width: 20,),
//                                 Icon(CupertinoIcons.gear),
//                                 SizedBox(width: 10,),
//                                 Text("${data['NoMesin']}"),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               // crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 // SizedBox(width: 20,),
//                                 SvgPicture.asset(
//                                   'assets/icons/kerangkamobil.svg', // Ganti dengan path ke file SVG Anda
//                                   width: 25,
//                                   height: 25,
//                                   color: Colors.black,
//                                 ),
//                                 SizedBox(width: 10,),
//                                 Text("${data['NoKerangka']}"),
//                               ],
//                             ),
//                             // Text("Plat: ${data['Plat']}"),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                                   }).toList(),
//                                 )
//                   : Container(),
//               SizedBox(height: 10,),
//               SizedBox(
//                 height: 45,
//                 width: MediaQuery.of(context).size.width / 2.25,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (selectedValue != null) {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           // builder: (context) => HomeScreen(email: selectedValue!),
//                           builder: (context) => HomeBottom(plat: selectedValue!,),
//                         ),
//                       );
//                     }
//                   },
//                   style: ButtonStyle(
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     backgroundColor: MaterialStateProperty.all<Color>(
//                         button
//                     ),
//                   ),
//                   child: Text('Pilih Kendaraan', style: TextStyle(color: textbutton),),
//                 ),
//               ),
//               SizedBox(height: 10,),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
