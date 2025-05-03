import 'dart:math';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../components/app_bar.dart';
import '../../components/plan_card.dart'; // 여행 계획 카드 컴포넌트
import '../../components/placeinfo_card.dart';
import '../../components/proceed_button.dart'; // 버튼 컴포넌트
import '../add_page/add_page_0.dart';
import '../add_page/add_page_2.dart';
import '../add_page/add_page_3.dart';

class HomePage extends StatefulWidget {
  final String? accessToken;
  const HomePage({super.key, this.accessToken});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  Map<String, dynamic>? _nearestPlan;
  String? _currentUsername;
  Map<String, dynamic>? _recommendedPlace;

  @override
  void initState() {
    super.initState();
    fetchPlans();
    _fetchRecommendedPlace();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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

  Future<void> _fetchRecommendedPlace() async {
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://conever.duckdns.org:8000/tour/recommend/?user_id=111&areaCode=1'),
    );

    channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data["status"] == "SUCCESS" && data["result"] != null) {
        final List<dynamic> courses = data["result"];
        final List<dynamic> flatPlaces = courses.expand((course) => course).toList();
        final filteredPlaces = flatPlaces.where((place) => (place['image1'] ?? '').isNotEmpty).toList();

        if (filteredPlaces.isNotEmpty) {
          final random = Random();
          final selectedPlace = filteredPlaces[random.nextInt(filteredPlaces.length)];

          setState(() {
            _recommendedPlace = selectedPlace;
          });
        }
      }
    });
  }

  // AddPage_0에서 여행 생성 완료 후 전달된 tourId와 AddPage_2에서 선택한 장소 정보들을 함께 받아 서버에 POST 요청
  Future<void> saveTourCourse(int tourId, List<PlaceInfoBlock> places) async {
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';

    try {
      // 여행 시작일을 불러오기 위한 GET 요청
      final startDateResponse = await dio.get(
        '$baseUrl/tour/$tourId/',
        options: Options(headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        }),
      );
      final startDate = startDateResponse.data['start_date'];

      // 장소 정보를 서버에 맞는 포맷으로 변환 (name, mapX, mapY, image, address)
      final List<Map<String, dynamic>> courseData = places.map((place) => {
        'name': '<${place.title}>',
        'mapX': place.mapX,
        'mapY': place.mapY,
        'image': place.imageUrl,
        'road_address': '<${place.description}>'
      }).toList();

      // 최종 코스 정보를 서버에 저장 요청
      final response = await dio.post(
        '$baseUrl/tour/course/',
        data: {
          'tour_id': '$tourId',
          'date': startDate,
          'places': courseData,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        }),
      );

      // 저장 성공 시 콘솔에 출력
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('경로 저장 완료');
      } else {
        print('저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('예외 발생: $e');
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
        controller: _scrollController,

        // 사용자 임의 스크롤 제한 -> 버튼을 통해서만 이동
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.066),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.024),
              Text(
                _currentUsername ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
              Text(
                  "하이요",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  )
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.024),
              Text(
                '⏰다가오는 일정',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.072,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.012),

              // ⬇️ PlanCard 위젯: 여행 카드의 크기를 반응형으로 지정
              Center(
                child: PlanCard(
                  tour_id: 1,
                  title: "성북구 산책",
                  startDate: "2025.03.18",
                  endDate: "2025.03.25",
                  size_h: MediaQuery.of(context).size.height * 0.394,
                  size_w: MediaQuery.of(context).size.width * 0.8,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              Center(
                child: ProceedButton(
                  size_w: MediaQuery.of(context).size.width * 0.586,
                  size_h: MediaQuery.of(context).size.height * 0.055,
                  text: "✨새로운 장소 탐험하기",
                  fontSize_: MediaQuery.of(context).size.width * 0.033,
                  fontWeight_: FontWeight.bold,
                  padding_: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.032,
                    horizontal: MediaQuery.of(context).size.height * 0.014,
                  ),
                  onTap: _scrollToBottom,
                ),
              ),

              // 트렌딩 버튼 하단에 여백 추가
              SizedBox(height: MediaQuery.of(context).size.height * 0.09),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
                child: Text(
                  "오늘\n이런 곳은 어떤가요?",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.0748,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              // 장소데이터 로딩 완료됐을 경우
              if (_recommendedPlace != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _recommendedPlace?['image1'] ?? '',
                        width: MediaQuery.of(context).size.width * 0.87,
                        height: MediaQuery.of(context).size.width * 0.55,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: MediaQuery.of(context).size.width * 0.045, color: Colors.black),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.013),
                        Text(
                          _recommendedPlace?['title'] ?? '',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.037,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.007),
                    Text(
                      (_recommendedPlace?['title'] != null && _recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                          ? "${_recommendedPlace?['title']}은(는) ${(_recommendedPlace?['address'] as String).split(' ')[1]}의 관광지 입니다.\n${_currentUsername ?? ''} 님의 마음에 드셨으면 좋겠네요!"
                          : '',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.017),
                    Center(
                      child: ProceedButton(
                        size_w: MediaQuery.of(context).size.width * 0.5,
                        size_h: MediaQuery.of(context).size.height * 0.05,
                        text: (_recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                            ? "${(_recommendedPlace?['address'] as String).split(' ')[1]} 코스 생성하기"
                            : "코스 생성하기",
                        fontSize_: MediaQuery.of(context).size.width * 0.032,
                        fontWeight_: FontWeight.bold,
                        padding_: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.012,
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                        ),
                        onTap: () {

                          // AddPage_2 → AddPage_0 → AddPage_3로 이동하는 코스 생성 플로우
                          //  선택한 지역(sigun)을 기준으로 AddPage_2에 전달
                          //  '이 코스로 할게요!' 누르면 콜백을 통해 AddPage_0로 이동
                          //  여행 제목 및 날짜 입력 후 '새 여행 만들기' 누르면 최종적으로 saveTourCourse 실행 및 완료 페이지로 이동
                          final String sigun = (_recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                              ? (_recommendedPlace?['address'] as String).split(' ')[1]
                              : '';
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => AddPage_2(
                                title: sigun,
                                tourId: 0, // Placeholder, will be replaced after AddPage_0
                                accessToken: widget.accessToken,
                                onSaveCourseCallback: (places) {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => AddPage_0(
                                        accessToken: widget.accessToken,
                                        onFinishCreation: (int tourId) {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (_) => AddPage_3(
                                                tour_id: tourId,
                                                accessToken: widget.accessToken,
                                              ),
                                            ),
                                          );
                                          // Save course with the tourId
                                          saveTourCourse(tourId, places);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )

                // 장소 데이터가 아직 로딩되지 않았을 때 회색 박스 표시
              else
                Column(
                  children: [
                    //SizedBox(height: MediaQuery.of(context).size.height * 0.024),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.87,
                        height: MediaQuery.of(context).size.width * 0.77,
                        color: Colors.grey[300],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ],
                ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.017),

              // 맨 상단으로 되돌아가기 버튼
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(
                    Icons.arrow_drop_up,
                    color: Colors.grey,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  label: Text(
                    '홈으로 이동',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: MediaQuery.of(context).size.width * 0.025,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.092),
            ],
          ),
        ),
      ),
    );
  }
}

