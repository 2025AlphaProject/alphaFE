import 'package:flutter/material.dart';
import '../components/app_bar.dart';
import '../components/plan_card.dart'; // PlanCard import

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "홈 앱바 영역"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 여백 추가
        child: Column(
          children: [
            PlanCard(
              title: "성북구 산책",
              startDate: "2025.03.18",
              endDate: "2025.03.25",
            ),
            const SizedBox(height: 16), // 간격 추가
            PlanCard(
              title: "강남구 탐방",
              startDate: "2025.04.01",
              endDate: "2025.04.05",
            ),
          ],
        ),
      ),
    );
  }
}
