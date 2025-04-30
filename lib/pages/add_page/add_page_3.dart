import 'package:flutter/material.dart';
import '../../components/app_bar.dart';

class AddPage_3 extends StatelessWidget {
  final String message; // 정상 등록 여부 확인 텍스트
  const AddPage_3({
    required this.message,
    Key? key
  }) : super(key: key);

  // "이 코스로 할게요!" 버튼 탭할 시 연결되어야 할 페이지, 경로 확정됨
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "추가페이지_3rd"),
      body: Center(
        child: Text(message),
      ),
    );
  }
}