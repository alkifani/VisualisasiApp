import 'package:flutter/material.dart';
import 'package:ta_visualisasi/configure/size_config.dart';

// const button = Color.fromRGBO(255, 221, 154, 1.0);
const button2 = Color.fromRGBO(206, 90, 103, 1.0);
const button = Color.fromRGBO(73, 75, 75, 1.0);
const background2 = Color.fromRGBO(244, 191, 150, 1.0);
const background = Color.fromRGBO(147, 177, 166, 1.0);
const header = Color.fromRGBO(0, 60, 67, 1.0);
const header2 = Color.fromRGBO(206, 90, 103, 1.0);

const texticon = Color.fromRGBO(255, 255, 255, 1.0);
const textbutton = Color.fromRGBO(255, 255, 255, 1.0);
const textheader = Color.fromRGBO(255, 255, 255, 1.0);
const leadingcolor = Color.fromRGBO(255, 255, 255, 1.0);

const cocolor = Color.fromRGBO(225, 96, 0, 1);
const cobuttoncolor = Color.fromRGBO(255, 230, 199, 1.0);
const kPrimaryColor = Color(0xFFFFA559);
const kPrimaryLightColor = Color(0xFFFFECDF);
// const kPrimaryGradientColor = LinearGradient(
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF050505);

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

final otpInputDecoration = InputDecoration(
  contentPadding:
  EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: const BorderSide(color: kTextColor),
  );
}
