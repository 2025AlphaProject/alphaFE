import 'package:flutter/material.dart';
import '../../components/app_bar.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "계획 앱바 영역"),
      body: const Center(
        child: Text("계획 페이지 콘텐츠"),
      ),
    );
  }
}
