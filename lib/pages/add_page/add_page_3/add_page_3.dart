import 'package:alpha_fe/pages/add_page/add_page_3/view_model/show_final_tour_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../components/appbars/default_appbar/default_appbar.dart';
import '../../../components/plan_card.dart';
import '../../../components/proceed_button.dart';
import 'package:provider/provider.dart';

import '../../plan_page/plan_page_1/plan_page.dart';


class AddPage_3 extends StatefulWidget {

  final int tour_id; // 정상 등록 여부 확인 텍스트
  const AddPage_3({
    required this.tour_id,
    Key? key,
  }) : super(key: key);

  @override
  State<AddPage_3> createState() => _AddPage_3State();
}

class _AddPage_3State extends State<AddPage_3> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ShowFinalTourViewModel>(context, listen: false)
          .fetchTourData(context, widget.tour_id);
    });
  }

  // "이 코스로 할게요!" 버튼 탭할 시 연결되어야 할 페이지, 경로 확정됨
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }

    final viewModel = context.watch<ShowFinalTourViewModel>();
    final tourData = viewModel.tourData;
    final isLoading = viewModel.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "추가하기 완료"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: height * 0.075),

          // 축하 이모지
          const Text('🥳', style: TextStyle(fontSize: 49.3)),

          SizedBox(height: height * 0.015),

          // 상단 텍스트
          const Text(
            "새 여행이 추가됐어요!",
            style: TextStyle(
              fontSize: 24.6,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: height * 0.035),

          // PlanCard로 구성된 회색 박스
          isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: PlanCard(
                  title: tourData?['tour_name'] ?? '',
                  startDate: tourData?['start_date'] ?? '',
                  endDate: tourData?['end_date'] ?? '',
                  size_h: height * 0.38,
                  size_w: width * 0.75,
                  tour_id: widget.tour_id,
                ),
              ),

          const Spacer(),

          // 하단 버튼
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.04),
            child: ProceedButton(
              size_w: width * 0.7,
              size_h: height * 0.055,
              text: '나의 계획에서 보기',
              fontSize_: 16.5,
              fontWeight_: FontWeight.bold,
              onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlanPage(),
                      ),
                  );
              },
            ),
          )
        ],
      ),
    );
  }
}