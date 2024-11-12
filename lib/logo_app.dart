// ignore_for_file: use_key_in_widget_constructors

import 'package:ta_visualisasi/configure/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ta_visualisasi/user/sign_in.dart';

class LogoApp extends StatefulWidget {
  static const routeName = "/Logo_App";

  @override
  State<LogoApp> createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, SignIn.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      //backgroundColor: Color.fromRGBO(255, 230, 173, 1.0),
      // backgroundColor: Color.fromRGBO(23, 107, 135, 1),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/black_box2.png'),
                  ),
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 25.0),
              child: Text(
                'Black-Box Visualization © 2024',
                style: TextStyle(
                  fontSize: 15,
                  //fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
