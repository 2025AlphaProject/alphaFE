import 'package:flutter/material.dart';
import '../pages/connection_example.dart'; // Import the new page

class PlanCard extends StatelessWidget {
  final String title; // 카드 제목
  final String startDate; // 시작 날짜 (YYYY.MM.DD 형식)
  final String endDate; // 끝 날짜 (YYYY.MM.DD 형식)

  const PlanCard({
    Key? key,
    required this.title,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  // 남은 날 계산 함수
  int calculateRemainingDays(String endDate) {
    final today = DateTime.now(); // 현재 날짜
    final endDateObj = DateTime.parse(endDate.replaceAll('.', '-')); // 종료 날짜를 DateTime으로 변환
    final difference = endDateObj.difference(today); // 차이 계산
    return difference.inDays; // 남은 날 반환
  }

  // 날짜 범위 문자열 생성
  String get dateRange => "$startDate ~ $endDate";

  @override
  Widget build(BuildContext context) {
    final remainingDays = calculateRemainingDays(endDate); // 남은 날 계산

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConnectionPageExample()), // Navigate to the new page
        );
      },
      child: Card(
        color: Color(0xFFF5F5F5),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 40), // 내부 여백 조정
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 세로축 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 가로축 중앙 정렬
            mainAxisSize: MainAxisSize.min, // 내용에 맞게 크기 조정
            children: [
              Card(
                color: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                margin: const EdgeInsets.all(5),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 1),
                  child: Text("D-$remainingDays",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8), // 간격 추가
              Text(title,
                  style:
                  TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min, // Row 크기를 내용에 맞게 조정
                mainAxisAlignment:
                MainAxisAlignment.center, // Row 내부 요소 중앙 정렬
                children: [
                  Icon(Icons.calendar_today,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(dateRange,
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
