import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../components/app_bar.dart';
import '../../components/plan_card.dart'; // 여행 계획 카드 컴포넌트
import '../../components/proceed_button.dart'; // 버튼 컴포넌트

class HomePage extends StatefulWidget {
  final String? accessToken;
  const HomePage({super.key, this.accessToken});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _nearestPlan;
  String? _currentUsername;

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
            'Authorization': 'Bearer ${widget.accessToken}',
            'Accept': 'application/json'
          },
        ),
      );

      // 현재 사용자 이름 추출
      final currentUsername = userResponse.data['username'];
      setState(() {
        _currentUsername = currentUsername;
      });

      // /tour/ API 호출하여 전체 여행 목록 가져오기
      final tourResponse = await dio.get(
        '$baseUrl/tour/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${widget.accessToken}',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.066), // 좌우 여백 설정

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 유저 이름
              Text(
                _currentUsername ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                )
              ),

              // 웰컴 메세지
              Text(
                  "하이요",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  )
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.024,),
              Text(
                '⏰다가오는 일정',
                style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.072, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.012,),
              Center(
                child: PlanCard(
                  title: "성북구 산책",
                  startDate: "2025.03.18",
                  endDate: "2025.03.25",
                  size_h: MediaQuery.of(context).size.height*0.394,
                  size_w: MediaQuery.of(context).size.width*0.8, tour_id: 1,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.073,),
              Center(
                /*
                * size_w, size_h, fontSize_ : double
                * text : String
                * fontWeight_ : FontWeight
                * padding_ : EdgeInsetsGeometry
                * */
                child: ProceedButton(
                    size_w: MediaQuery.of(context).size.width*0.586,
                    size_h: MediaQuery.of(context).size.height*0.055,
                    text: "✨새로운 장소 탐험하기",
                    fontSize_: 15,
                    fontWeight_: FontWeight.bold,
                    padding_: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.032, horizontal: MediaQuery.of(context).size.height*0.014)
                )

                /*ElevatedButton(
                  onPressed: () {
                  },

                  // 버튼 스타일 지정 (크기, 색상, 모서리 둥글기 등)
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(220, 45),
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                    backgroundColor: Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: Center(
                    child: Text(
                      "✨새로운 장소 탐험하기",
                      style: TextStyle(
                        color: Color(0xFFF5F5F5),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),*/
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
                child: Text(
                  "오늘\n이런 곳은 어떤가요?",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width*0.0748,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // 이미지 추가 (클릭 시 해당 페이지 바로 이동)
              // 사진 받아 오는 API 아무거나 물어보기
            ],
          ),
        ),
      ),
    );
  }
}