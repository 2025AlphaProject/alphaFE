import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../components/app_bar.dart';
import '../../components/logout_by_expiration.dart';
import '../../components/plan_card.dart';
import '../../components/proceed_button.dart';
import '../../components/token_controller.dart';
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
    final accessToken = await getAccessToken();
    final dio = Dio();

    final url = 'http://conever.duckdns.org:8000/tour/${widget.tour_id}/';
    try {
      final response = await dio.get(
          url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        final bool? result = await getAccessTokenFromRefreshToken();
        if (result == false) {
          LogoutByExpiration(context);
        }
        await fetchTourData();
      }

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
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
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
          _tourData == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: PlanCard(
                  title: _tourData!['tour_name'] ?? '',
                  startDate: _tourData!['start_date'] ?? '',
                  endDate: _tourData!['end_date'] ?? '',
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
                          builder: (context) => const PlanPage(),
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