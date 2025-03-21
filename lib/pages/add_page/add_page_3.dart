import 'package:flutter/material.dart';
import '../../components/app_bar.dart';

class AddPage_3 extends StatelessWidget {
  const AddPage_3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "추가페이지_3rd"),
      body: Center(
        child: Text("컨텐츠 영역"),
      ),
    );
  }
}