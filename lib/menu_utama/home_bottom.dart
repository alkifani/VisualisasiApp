import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/configure/my_flutter_app_icons.dart';
import 'package:ta_visualisasi/logo_app.dart';
import 'package:ta_visualisasi/menu_utama/about_us.dart';
import 'package:ta_visualisasi/menu_utama/data_grafik.dart';
import 'package:ta_visualisasi/menu_utama/maps/maps_animation.dart';
import 'package:ta_visualisasi/menu_utama/tilt_history/animasi_kemiringan.dart';
import 'package:ta_visualisasi/menu_utama/tilt_history/tilt_animation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ta_visualisasi/menu_utama/transfer_data/pilih_metode_transfer.dart';
import 'package:ta_visualisasi/menu_utama/transfer_data/transfer_data_alat/konfigurasi_bluetooth.dart';
import 'package:ta_visualisasi/menu_utama/transfer_data/transfer_data_hp.dart';
import 'package:ta_visualisasi/menu_utama/upload_data/upload_data.dart';
import 'package:ta_visualisasi/user/sign_in.dart';

class HomeBottom extends StatefulWidget {
  // const HomeBottom({super.key});
  final String plat;

  const HomeBottom({Key? key, required this.plat}) : super(key: key);

  @override
  State<HomeBottom> createState() => _HomeBottomState();
}

class _HomeBottomState extends State<HomeBottom> {
  int _selectedIndex = 0;

  // Function to handle log out
  Future<void> _handleLogout(BuildContext context) async {
    // Remove token otentikasi dari shared_preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');

    // Navigate ke halaman login dan hapus semua route sebelumnya
    Navigator.of(context).pushAndRemoveUntil(
      // MaterialPageRoute(builder: (context) => LogoApp()),
      MaterialPageRoute(builder: (context) => SignIn()),
          (Route<dynamic> route) => false, // Menghapus semua route sebelumnya dan hanya menampilkan halaman login
    );
  }

  @override
  Widget build(BuildContext context) {
    //final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait; //mendeteksi layar
    return Scaffold(
      backgroundColor: background,
      appBar: // isPortrait ?
      AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: header,
        // elevation: 20,
        // title: const Text('GoogleNavBar'),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              'assets/icons/plat2.svg', // Ganti dengan path ke file SVG Anda
              width: 40,
              height: 40,
              color: texticon,
            ),
            Text(
              "${widget.plat}",
              style: TextStyle(
                fontSize: 20,
                color: textheader,
                fontWeight: FontWeight.bold,
              ),
            ),
            // IconButton(
            //   onPressed: () {
            //   },
            //   icon: Icon(MyFlutterApp.menu_1, size: 20),
            // )
            PopupMenuButton <String>(
              iconColor: texticon,
                color: header,
                offset: Offset(0, 60),
                onSelected: (value) {
                  if (value == 'Item 1') {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => AboutUs()),
                    // );
                  } else if (value == 'Item 2') {
                    _handleLogout(context);
                  } else if (value == 'Item 3') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DataTransfer(plat: widget.plat)),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>> [
                    PopupMenuItem<String>(
                        value: 'Item 3',
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.arrow_2_circlepath_circle, color: texticon,),
                            SizedBox(width: 5,),
                            Text('Transfer Data', style: (TextStyle(color: texticon)),),
                          ],
                        )
                    ),
                    // PopupMenuItem<String>(
                    //     value: 'Item 1',
                    //     child: Row(
                    //       children: [
                    //         Icon(CupertinoIcons.info, color: texticon,),
                    //         SizedBox(width: 5,),
                    //         Text('About Us', style: (TextStyle(color: texticon))),
                    //       ],
                    //     )
                    // ),
                    PopupMenuItem<String>(
                        value: 'Item 2',
                        child: Row(
                          children: [
                            Icon(Icons.logout_outlined, color: texticon,),
                            SizedBox(width: 5,),
                            Text('Logout', style: (TextStyle(color: texticon))),
                          ],
                        )
                    ),
                  ];
                })
          ],
        ),
      ),
     // : null, //fungsi menghilangkan appbar
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // DataHome(email: widget.email),
          DataGrafik(plat: widget.plat),
          // GrafDistanceHistory(email: widget.email),
          //AnimasiKemiringan(plat: widget.plat),
          MapsApp(plat: widget.plat),
          TiltAnimation(plat: widget.plat,),
        ],
      ),
      bottomNavigationBar: Container(
        color: header,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: texticon,
              // activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.black54,
              // tabBackgroundColor: Colors.grey[100]!,
              backgroundColor: header,
              color: Colors.black,
              tabs: [
                // GButton(
                //   icon: Icons.home,
                //   text: 'Home',
                // ),
                GButton(
                  iconColor: texticon,
                  textColor: texticon,
                  icon: CupertinoIcons.graph_square,
                  text: 'Graphics',
                ),
                GButton(
                  iconColor: texticon,
                  textColor: texticon,
                  icon: MyFlutterApp.maps,
                  text: 'Maps',
                ),
                GButton(
                  iconColor: texticon,
                  textColor: texticon,
                  icon: CupertinoIcons.car_detailed,
                  text: 'Visualization',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}