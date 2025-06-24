import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../viewModel/plan_sort_viewModel.dart';
import 'package:provider/provider.dart';
import 'package:alpha_fe/providers/auth_provider.dart';
import 'page_indicator.dart';
import '../../../../components/plan_card.dart';

// 여행이 없을 때 표시되는 안내 위젯
class EmptyPlan extends StatelessWidget {
  const EmptyPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('등록된 여행이 없습니다.', style: TextStyle(fontSize: 18.5)),
          Text(
            '여행을 추가해주세요!',
            style: TextStyle(fontSize: 24.6, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

//여행이 있을 때 표시되는 리스트
class PlanList extends StatelessWidget {
  const PlanList({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (kIsWeb) {
      width = 430;
    }
    final vm = context.watch<SortViewModel>();
    final initialPage = vm.getInitialPageIndex();
    final PageController _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: initialPage,
    );
    final cards = vm.sortedCardData;
    final accessToken = Provider.of<AuthProvider>(context, listen: false).accessToken;

    return Column(
      children: [
        SizedBox(height: height * 0.12), //여백용

        //여행 카드 목록
        SizedBox(
          height: height * 0.4,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            controller: _pageController,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final item = cards[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                child: PlanCard(
                  title: item['title']!,
                  startDate: item['startDate']!,
                  endDate: item['endDate']!,
                  size_h: height * 0.5,
                  size_w: width * 0.65,
                  tour_id: item['tour_id'],
                  accessToken: accessToken,
                ),
              );
            },
          ),),

        SizedBox(height: height * 0.03), //여백용

        // 페이지 인디케이터
        PlanPageIndicator(
          controller: _pageController,
          count: cards.length,
          dotSize: width * 0.02,
          dotActiveWidth: width * 0.03,
        ),
      ],
    );
  }
}
