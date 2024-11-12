
import 'package:flutter/material.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/transfer_data/transfer_data_alat/konfigurasi_bluetooth.dart';
import 'package:ta_visualisasi/menu_utama/transfer_data/transfer_data_hp.dart';


class PilihMetodeTransfer extends StatefulWidget {
  // const PilihMetodeTransfer({super.key});
  final String plat;

  const PilihMetodeTransfer({Key? key, required this.plat}) : super(key: key);

  @override
  State<PilihMetodeTransfer> createState() => _PilihMetodeTransferState();
}

class _PilihMetodeTransferState extends State<PilihMetodeTransfer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        title: Text('Pilih Metode Transfer', style: TextStyle(color: textheader),),
        iconTheme: IconThemeData(color: textheader),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width / 1.50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // builder: (context) => HomeScreen(email: selectedValue!),
                      builder: (context) => KonfigurasiBluetooth(plat: widget.plat),
                    ),
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      button
                  ),
                ),
                child: Text('Transfer Data Menggunakan Alat', style: TextStyle(color: textbutton),),
              ),
            ),
            SizedBox(height: 10,),
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width / 1.50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // builder: (context) => HomeScreen(email: selectedValue!),
                      builder: (context) => DataTransfer(plat: widget.plat),
                    ),
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  alignment: Alignment.center,
                  backgroundColor: MaterialStateProperty.all<Color>(
                      button
                  ),
                ),
                child: Text('Transfer Data Menggunakan Aplikasi',
                  style: TextStyle(color: textbutton,), textAlign: TextAlign.center, ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
