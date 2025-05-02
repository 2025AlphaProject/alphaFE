import 'package:flutter/material.dart';
import '/pages/add_page/add_page_3.dart';
import '/components/app_bar.dart'; // 필요한 경우

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddPage_3(tour_id: 1), // ← 여기에 원하는 위젯 넣으면 됨
    ),
  );
}