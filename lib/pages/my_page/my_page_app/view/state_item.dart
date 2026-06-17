import 'package:flutter/material.dart';

//여행수랑 미션수 나타내는 위젯
Widget StateItem(String value, String label, double width, double height) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 24.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: height * 0.002),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 12.3,
        ),
      ),
    ],
  );
}
