import 'package:flutter/material.dart';

class StyleList {
  static const backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment(0.00, -1.00),
      end: Alignment(0, 1),
      colors: [Color(0xFF839EAE), Colors.white],
    ),
  );

  static const buttonColor = Color(0xFF244167);
  static const bottomRowSecondaryButtonColor = Color.fromARGB(255, 87, 87, 87);
  static const bottomRowSecondaryButtonColorInactive = Color.fromARGB(32, 87, 87, 87);
}
