import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'add_page_3.dart';
import '../../components/app_bar.dart';

class AddPage_2 extends StatelessWidget {
  final String title;
  final String place;

  const AddPage_2({
    required this.title,
    required this.place,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "추가페이지_2nd"),

      body: Stack(
        // "이 코스로 할게요!" 버튼이 다른 UI 요소 위에 그려지도록 하기 위해 Stack 사용
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              // Stack + ScrollView 조합 시, 자식 요소가 화면을 벗어나 배치되는 문제 방지를 위해 사용
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height, // 최소 높이를 화면 크기로 제한
                  minWidth: MediaQuery.of(context).size.width
              ),

              // 코스 정보를 담은 UI 블록들을 수직으로 배치
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title, $place",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),

          // "이 코스로 할게요!" 버튼을 화면 하단에 고정 배치
          Positioned(
            bottom: 90,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => AddPage_3(),
                  ),
                );
              },

              // 버튼 스타일 지정 (크기, 색상, 모서리 둥글기 등)
              style: ElevatedButton.styleFrom(
                fixedSize: Size(250, 45),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                backgroundColor: Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: Center(
                child: Text(
                  "이 코스로 할게요!",
                  style: TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}