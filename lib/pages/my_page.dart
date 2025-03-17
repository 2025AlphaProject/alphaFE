import 'package:flutter/material.dart';
import '../components/app_bar.dart';


class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "마이 앱바 영역"),
      body: const Center(
        child: Text("마이 페이지 콘텐츠"),
      ),
    );
  }
}
