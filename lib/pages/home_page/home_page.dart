import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import '../../components/plan_card.dart'; // 여행 계획 카드 컴포넌트
import '../../components/proceed_button.dart'; // 버튼 컴포넌트

class HomePage extends StatelessWidget {
  final String? username;
  final String welcome_message;

  const HomePage({
    required this.username,
    required this.welcome_message,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      // 상단 앱바
      appBar: const SearchAppBar(),

      // 콘텐츠 영역
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25), // 좌우 여백 설정

        // 여행 계획 카드요소 및 텍스트 세로 방향으로 나열
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 유저 이름
            Text(
              '$username님,',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
            ),

            // 웰컴 메세지
            Text(
                '$welcome_message',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
            ),
            SizedBox(height: 20,),
            Text(
              '⏰다가오는 일정',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            Center(
              child: PlanCard(
                title: "성북구 산책",
                startDate: "2025.03.18",
                endDate: "2025.03.25",
                size_h: 320,
                size_w: 300,
              ),
            ),
            SizedBox(height: 60,),
            Center(
              /*
              * size_w, size_h, fontSize_ : double
              * text : String
              * fontWeight_ : FontWeight
              * padding_ : EdgeInsetsGeometry
              * */
              child: ProceedButton(
                  size_w: 220,
                  size_h: 45,
                  text: "✨새로운 장소 탐험하기",
                  fontSize_: 15,
                  fontWeight_: FontWeight.bold,
                  padding_: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0)
              )

              /*ElevatedButton(
                onPressed: () {
                },

                // 버튼 스타일 지정 (크기, 색상, 모서리 둥글기 등)
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(220, 45),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                  backgroundColor: Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: Center(
                  child: Text(
                    "✨새로운 장소 탐험하기",
                    style: TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),*/
            ),
          ],
        ),
      ),
    );
  }
}