// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:ta_visualisasi/configure/routes.dart';
import 'package:ta_visualisasi/firebase_options.dart';
import 'package:ta_visualisasi/logo_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:ta_visualisasi/user/sign_in.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    // webRecaptchaSiteKey: 'recaptcha-v3-site-key'
    // Set androidProvider to `AndroidProvider.debug`
    androidProvider: AndroidProvider.debug,
  );

// You can request multiple permissions at once.
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.location,
//     Permission.storage,
//     Permission.manageExternalStorage,
//     Permission.phone,
//     Permission.accessMediaLocation,
//   ].request();
//   print(statuses[Permission.location]);
//   print(statuses[Permission.storage]);
//   print(statuses[Permission.manageExternalStorage]);


  // Set preferensi orientasi layar ke landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(await VisualisasiApp.initialize());
}

class VisualisasiApp extends StatefulWidget {
  // const VisualisasiApp({super.key});
  final String? authToken;

  VisualisasiApp({this.authToken});

  static Future<VisualisasiApp> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    return VisualisasiApp(authToken: authToken);
  }

  @override
  State<VisualisasiApp> createState() => _VisualisasiAppState();
}

class _VisualisasiAppState extends State<VisualisasiApp> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimeout();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimeout() {
    const timeout = Duration(minutes: 30);
    _timer = Timer(timeout, _handleTimeout);
  }

  void _handleTimeout() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('authToken');
      _handleLogout();
      // runApp(VisualisasiApp());
    });
  }

  void _restartTimeout() {
    _timer.cancel();
    _startTimeout();
  }

  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
// Dapatkan context yang valid dari widget VisualisasiApp
    BuildContext context = this.context;

    // Navigate ke halaman login dan hapus semua route sebelumnya
    Navigator.of(context).pushNamedAndRemoveUntil(
      SignIn.routeName,
          (Route<dynamic> route) => false, // Menghapus semua route sebelumnya dan hanya menampilkan halaman login
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Black-Box Visualization',
      themeMode: ThemeMode.system,
            // We use routeName so that we dont need to remember the name
      initialRoute: widget.authToken != null ?  LogoApp.routeName : SignIn.routeName,
      routes: routes,
      builder: (context, child) {
        _restartTimeout();
        return child!;
      },
    );
  }
}


// class MyApp extends StatelessWidget {
//   final String? authToken;
//   late Timer _timer;
//
//   MyApp({this.authToken}) {
//     _startTimeout();
//   }
//
//   static Future<MyApp> initialize() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? authToken = prefs.getString('authToken'); // Periksa apakah authToken bernilai null
//     return MyApp(authToken: authToken);
//   }
//
//   void _startTimeout() {
//     const timeout = Duration(minutes: 30);
//     _timer = Timer(timeout, _handleTimeout);
//   }
//
//   void _handleTimeout() {
//     SharedPreferences.getInstance().then((prefs) {
//       prefs.remove('authToken');
//       runApp(MyApp());
//     });
//   }
//
//   void _restartTimeout() {
//     _timer.cancel();
//     _startTimeout();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Black Box Visualisasi',
//       // theme: theme(),
//       themeMode: ThemeMode.system,
//       //theme: ThemeData(appBarTheme: AppBarTheme(backgroundColor: Colors.white, iconTheme: IconThemeData(color: Colors.black87))),
//       // theme: theme(),
//       //
//       //home: DataPlat(),
//       // We use routeName so that we dont need to remember the name
//       initialRoute: authToken != null ?  LogoApp.routeName : SignIn.routeName,
//       routes: routes,
//       builder: (context, child) {
//         _restartTimeout();
//         return child!;
//       },
//     );
//   }
// }
