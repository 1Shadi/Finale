import 'package:flutter/material.dart';

Widget circularProgress() {
  return Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(top: 12.0),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
    ),
  );
}