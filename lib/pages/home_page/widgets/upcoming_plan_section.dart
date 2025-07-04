import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/plan_card.dart';
import '../../../pages/add_page/add_page_0/add_page_0.dart';

class UpcomingPlanSection extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? nearestPlan;
  final double width;
  final double height;

  const UpcomingPlanSection({
    super.key,
    required this.isLoading,
    required this.nearestPlan,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⏰ 다가오는 일정',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: height * 0.012),
        Center(
          child: _buildCard(context),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: width * 0.8,
        height: height * 0.394,
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: const Color(0xFFF5F5F5),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    if (nearestPlan != null) {
      return PlanCard(
        title: nearestPlan!['title'],
        startDate: nearestPlan!['start_date'],
        endDate: nearestPlan!['end_date'],
        size_h: height * 0.394,
        size_w: width * 0.8,
        tour_id: nearestPlan!['id'],
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => AddPage_0(),
          ),
        );
      },
      child: Container(
        width: width * 0.8,
        height: height * 0.394,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 37.5, color: Color(0xFFB5B5B5)),
              SizedBox(height: 10),
              Text(
                '이런, 여행이 없어요🧐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB5B5B5),
                ),
              ),
              Text(
                '여행을 추가해주세요!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB5B5B5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}