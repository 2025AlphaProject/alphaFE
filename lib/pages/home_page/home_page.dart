import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../components/app_bar.dart';
import '../../components/plan_card.dart'; // 여행 계획 카드 컴포넌트
import '../../components/proceed_button.dart'; // 버튼 컴포넌트
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  final String? username;
  final String welcome_message;

  const HomePage({
    required this.username,
    required this.welcome_message,
    Key? key
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _nearestPlan;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';

    try {

      // /user/me/ API 호출하여 현재 사용자 정보 가져오기
      final userResponse = await dio.get(
        '$baseUrl/user/me/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${dotenv.env['KAKAO_ACCESS_TOKEN']}',
            'Accept': 'application/json'
          },
        ),
      );

      // 현재 사용자 이름 추출
      final currentUsername = userResponse.data['username'];

      // /tour/ API 호출하여 전체 여행 목록 가져오기
      final tourResponse = await dio.get(
        '$baseUrl/tour/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${dotenv.env['KAKAO_ACCESS_TOKEN']}',
            'Accept': 'application/json'
          },
        ),
      );

      // 전체 여행 목록에서 현재 사용자 이름과 일치하는 여행만 필터링
      final List<dynamic> allPlans = tourResponse.data;
      final List<dynamic> userPlans = allPlans.where((plan) {
        final List<dynamic> users = plan['user'] ?? [];
        return users.any((u) => u['username'] == currentUsername);
      }).toList();

      // 여행 계획이 존재하는지 확인
      if (userPlans.isNotEmpty) {

        // 현재 시각을 기준으로 가장 가까운 여행 계획을 찾기 위해 현재 시각 저장
        DateTime now = DateTime.now();

        // 필터링된 여행 계획 리스트를 시작 날짜와 현재 시각 간의 차이 절대값 기준으로 오름차순 정렬
        userPlans.sort((a, b) {
          DateTime aStart = DateTime.parse(a['start_date']);
          DateTime bStart = DateTime.parse(b['start_date']);
          Duration aDiff = aStart.difference(now).abs();
          Duration bDiff = bStart.difference(now).abs();
          return aDiff.compareTo(bDiff);
        });

        // 가장 가까운 여행 계획을 상태에 저장하고 로딩 상태를 false로 변경하여 UI 갱신
        setState(() {
          _nearestPlan = userPlans.first;
          _isLoading = false;
        });
      } else {

        // 여행 계획이 없을 경우, null로 설정하고 로딩 상태를 false로 변경
        setState(() {
          _nearestPlan = null;
          _isLoading = false;
        });
      }
    } catch (e) {

      // API 호출 실패 혹은 예외 발생 시, 여행 계획을 null로 설정하고 로딩 상태를 false로 변경
      setState(() {
        _nearestPlan = null;
        _isLoading = false;
      });
    }
  }

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
              '${widget.username}님,',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
            ),

            // 웰컴 메세지
            Text(
                '${widget.welcome_message}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
            ),
            SizedBox(height: 20,),
            Text(
              '⏰다가오는 일정',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : (_nearestPlan != null
                      ? PlanCard(
                          title: _nearestPlan!['tour_name'],
                          startDate: _nearestPlan!['start_date'],
                          endDate: _nearestPlan!['end_date'],
                          size_h: 320,
                          size_w: 300,
                        )
                      : Text('예정된 일정이 없습니다.')),
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
            ),
          ],
        ),
      ),
    );
  }
}