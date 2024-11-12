
import 'package:ta_visualisasi/logo_app.dart';
// import 'package:ta_visualisasi/upload_data/ambil_data.dart';
import 'package:flutter/material.dart';
import 'package:ta_visualisasi/user/reset_password.dart';
import 'package:ta_visualisasi/user/sign_in.dart';
import 'package:ta_visualisasi/user/sign_up.dart';

final Map<String, WidgetBuilder> routes = {
  LogoApp.routeName: (context) => LogoApp(),
  SignIn.routeName: (context) => SignIn(),
  SignUp.routeName: (context) => SignUp(),
  ResetPassword.routeName: (context) => ResetPassword(),
  // AmbilData.routeName: (context) {
  //   final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  //   final email = args['email'] as String;
  //   return AmbilData(email: email);
  // },
  // KonfigurasiBluetooth.routeName: (context) {
  //   final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  //   final email = args['email'] as String;
  //   return KonfigurasiBluetooth(email: email);
  // },
  // VideoPlayerWidget.routeName: (context) => VideoPlayerWidget(),
  // DistanceHistoryDisplay.routeName: (context) => DistanceHistoryDisplay(),
  // SpeedHistoryDisplay.routeName: (context) => SpeedHistoryDisplay(),
  //GPSHistoryDisplay.routeName: (context) => GPSHistoryDisplay(),
  //GrafDistanceHistory.routeName: (context) => GrafDistanceHistory(),
  //TiltHistoryDisplay.routeName: (context) => TiltHistoryDisplay(),
};
