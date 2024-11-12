
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/distance_history/graf_distance.dart';
import 'package:ta_visualisasi/menu_utama/speed_history/graf_speed.dart';

class DataGrafik extends StatefulWidget {
  // const DataGrafik({super.key});
  final String plat;

  const DataGrafik({Key? key, required this.plat}) : super(key: key);

  @override
  State<DataGrafik> createState() => _DataGrafikState();
}

class _DataGrafikState extends State<DataGrafik> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: MenuGrafik(plat: widget.plat)
    );
  }
}

class MenuGrafik extends StatefulWidget {
  // const MenuGrafik({super.key});
  final String plat;

  const MenuGrafik({Key? key, required this.plat}) : super(key: key);


  @override
  State<MenuGrafik> createState() => _MenuGrafikState();
}

class _MenuGrafikState extends State<MenuGrafik> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //SizedBox(height: getProportionateScreenHeight(10)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    child: GrafSpeedHistory(plat: widget.plat)),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Card(
              //       child:
              //       GrafDistanceHistory(plat: widget.plat)),
              // ),
              Container(
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning, // Ubah ikon sesuai kebutuhan Anda
                        color: Colors.red, // Warna ikon
                      ),
                      SizedBox(width: 5), // Spasi antara ikon dan teks
                      Text(
                        'The velocity is excessive',
                        style: TextStyle(color: Colors.red), // Warna teks
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
