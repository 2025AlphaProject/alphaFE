import 'package:alpha_fe/pages/plan_page/plan_page_2.dart';
import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final String title;      // 카드 제목
  final String startDate;  // 여행 시작 날짜 (형식: YYYY.MM.DD)
  final String endDate;    // 여행 종료 날짜 (형식: YYYY.MM.DD)
  final double size_h; // 카드의 높이
  final double size_w; // 카드의 너비

  const PlanCard({
    Key? key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.size_h,
    required this.size_w,
  }) : super(key: key);

  // 종료일까지 남은 일 수 계산
  int calculateRemainingDays(String endDate) {
    final today = DateTime.now();
    final endDateObj = DateTime.parse(endDate.replaceAll('.', '-'));
    final difference = endDateObj.difference(today);
    return difference.inDays;
  }

  // 시작일 ~ 종료일 형식의 날짜 범위 문자열 반환
  String get dateRange => "$startDate ~ $endDate";

  @override
  Widget build(BuildContext context) {
    final remainingDays = calculateRemainingDays(endDate);

    return SizedBox( // 카드 위젯의 크기 명시
      height: size_h,
      width: size_w,
      child: Card(
        clipBehavior: Clip.antiAlias, // 카드 외부 영역이 터지되지 않도록 처리함
      
        color: Color(0xFFF5F5F5),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlanPage2(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
      
              children: [
                // D-day 표시 영역
                Card(
                  color: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.all(5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 1),
                    child: Text(
                      "D-$remainingDays",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
      
                const SizedBox(height: 8),
      
                // 여행 제목
                Text(
                  title,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
      
                const SizedBox(height: 8),
      
                // 여행 날짜 범위 (달력 아이콘 + 텍스트)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      dateRange,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}