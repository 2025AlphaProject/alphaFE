import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import '../../components/plan_card.dart'; // 여행 계획 카드 컴포넌트

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      // 상단 앱바
      appBar: const DefaultAppBar(title: "홈 앱바 영역"),

      // 콘텐츠 영역
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 여백 설정

        // 여행 계획 카드요소 및 텍스트 세로 방향으로 나열
        child: Column(
          children: [
            PlanCard(
              title: "성북구 산책",
              startDate: "2025.03.18",
              endDate: "2025.03.25",
            ),
          ],
        ),
      ),
    );
  }
}