import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../components/app_bar.dart';
import '../../components/plan_card.dart';
import '../../components/proceed_button.dart';
import '../plan_page/plan_page.dart';
import 'package:alpha_fe/components/auth_token_handler.dart';


class AddPage_3 extends StatefulWidget {
  final int tour_id; // 정상 등록 여부 확인 텍스트
  const AddPage_3({
    required this.tour_id,
    Key? key
  }) : super(key: key);

  @override
  State<AddPage_3> createState() => _AddPage_3State();
}

class _AddPage_3State extends State<AddPage_3> {
  Map<String, dynamic>? _tourData;

  @override
  void initState() {
    super.initState();
    fetchTourData().then((data) {
      setState(() {
        _tourData = data;
      });
    });
  }

  Future<Map<String, dynamic>> fetchTourData() async {
    final dio = Dio();
    final url = 'http://conever.duckdns.org:8000/tour/${widget.tour_id}/';
    try {
      final response = await dio.get(url);
      return response.data;
    } catch (e) {
      print("❌ 여행 데이터 불러오기 실패: $e");
      return {
        'tour_name': '여행 이름 불러오기 실패',
        'start_date': '0000.00.00',
        'end_date': '0000.00.00',
      };
    }
  }

  // "이 코스로 할게요!" 버튼 탭할 시 연결되어야 할 페이지, 경로 확정됨
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "추가하기 완료"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.075),

          // 축하 이모지
          Text('🥳', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.12)),

          SizedBox(height: MediaQuery.of(context).size.height * 0.015),

          // 상단 텍스트
          Text(
            "새 여행이 추가됐어요!",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.035),

          // PlanCard로 구성된 회색 박스
          _tourData == null
            ? Center(child: const CircularProgressIndicator())
            : Center(
                child: PlanCard(
                  title: _tourData!['tour_name'] ?? '',
                  startDate: _tourData!['start_date'] ?? '',
                  endDate: _tourData!['end_date'] ?? '',
                  size_h: MediaQuery.of(context).size.height * 0.38,
                  size_w: MediaQuery.of(context).size.width * 0.75,
                  tour_id: widget.tour_id,
                ),
              ),

          const Spacer(),

          // 하단 버튼
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.04),
            child: ProceedButton(
              size_w: MediaQuery.of(context).size.width * 0.7,
              size_h: MediaQuery.of(context).size.height * 0.055,
              text: '나의 계획에서 보기',
              fontSize_: MediaQuery.of(context).size.width * 0.04,
              fontWeight_: FontWeight.bold,
              padding_: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              onTap: () async {
                final accessToken = await getAccessTokenFromRefreshToken();
                if (accessToken != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlanPage(
                              accessToken: accessToken
                          ),
                      ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}