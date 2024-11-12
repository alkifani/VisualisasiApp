import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/configure/my_flutter_app_icons.dart';


class AboutUs extends StatefulWidget {
  const AboutUs({super.key});
  // final String email;
  //
  // const AboutUs({Key? key, required this.email}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  // List of team members with their information
  final List<TeamMember> teamMembers = [
    TeamMember(
      name: "Ahmad Mufadhdhal Alkifani\nSoftware Programmer",
      image: 'assets/images/mufadhdhal.png',
    ),
    TeamMember(
      name: "T.Muhammad Caesar Maulana\nHardware Programmer",
      image: 'assets/images/caesar.png',
    ),
    TeamMember(
      name: "Humaira\nUI/UX Designer",
      image: 'assets/images/humaira.png',
    ),
    TeamMember(
      name: "Mhd. Daffa Adrian Sitorus\nUI/UX Designer",
      image: 'assets/images/dafa.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      //backgroundColor: Color.fromRGBO(255, 230, 173, 1.0),
      appBar: AppBar(
        backgroundColor: header,
        // backgroundColor: Color.fromRGBO(234, 186, 103, 1.0),
        //backgroundColor: Colors.white,
        // leading: IconButton(
        //   icon: const Icon(
        //     Icons.arrow_back,
        //     color: Colors.black87,
        //     size: 30,
        //   ),
        //   onPressed: () {
        //     // Navigator.push(
        //     //   context,
        //     //   MaterialPageRoute(
        //     //     builder: (context) => HomeScreen(),
        //     //   ),
        //     //);
        //     Navigator.of(context).pushAndRemoveUntil(
        //       MaterialPageRoute(builder: (context) => HomeScreen(email: widget.email)),
        //           (Route<dynamic> route) => false,
        //     );
        //   },
        // ),
        iconTheme: IconThemeData(color: textheader),
        title: const Text(
          'Tentang CO-SENSE',
          style: TextStyle(color: textheader),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Anggota Team',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Displaying each team member's information in a Card widget
            ...teamMembers.map((member) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xff2d4854), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(member.image),
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            const Text(
              'Apa itu Co-Sense?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Collision Sense atau Co-Sense merupakan sebuah sistem yang mampu merekam data perjalanan yang terdiri dari tracking lokasi, kecepatan, sudut kemiringan, dan jarak kendaraan dengan objek yang ada di depan. Dari data tersebut, sistem akan melakukan analisis dan mengambil keputusan penyebab terjadinya kecelakaan.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            const Text(
              'Spesifikasi Alat Co-Sense',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sistem COSENSE menggunakan sebuah minikomputer Raspberry Pi 3 model B+ yang sudah dilengkapi dengan konektivitas WiFi dan Bluetooth, sehingga dalam mengkomunikasikan data dapat berinteraksi dengan internet maupun tanpa internet. Dalam pembacaan data system dilengkapi dengan sensor gyroscope MPU6050, Webcam Logitech C270, dan GPS Module.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20,),
            InkWell(
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationIcon: SizedBox(
                    width: 50, // Ubah lebar
                    height: 50, // Ubah tinggi
                    child: Image.asset('assets/images/black_box.png'),
                  ),
                  applicationName: 'Tentang Aplikasi',
                  applicationVersion: 'V.1.0',
                  applicationLegalese: '© 2024 Developed by Team 7',
                  children: <Widget>[
                    const Text('Dikembangkan pada tahun 2023', textAlign: TextAlign.center,),
                  ],
                );
              },
              splashColor: Colors.blue,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(MyFlutterApp.info_logo, size: 25, color: Colors.black87,),
                  Text(
                    "Tentang Aplikasi CO-SENSE",
                    style: TextStyle(fontSize: 17.0, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String image;

  TeamMember({
    required this.name,
    required this.image,
  });
}
