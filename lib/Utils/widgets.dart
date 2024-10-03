import 'package:flutter/material.dart';

Widget customElevatedButton({
  required Color primary,        // Background color
  required Color onPrimary,      // Text color
  required VoidCallback onPressed, // onPressed function
  required String text,           // Button text
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(
          color: Color.fromRGBO(0, 0, 0, 0.09),
          width: 3,
        ),
      ),
    ),
    onPressed: onPressed,
    child: Text(
      text,
      style: TextStyle(fontSize: 15, color: onPrimary),
    ),
  );
}