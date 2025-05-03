import 'dart:math';
import 'dart:async';
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
import '../../components/token_controller.dart'; // 버튼 컴포넌트

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    final accessToken = await getAccessToken();
    print('accessToken:$accessToken');
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';

    try {

      // /user/me/ API 호출하여 현재 사용자 정보 가져오기
      final userResponse = await dio.get(
        '$baseUrl/user/me/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json'
          },
        ),
      );

      // 현재 사용자 이름 추출
      final currentUsername = userResponse.data['username'];
      if (!mounted) return;
      setState(() {
        _currentUsername = currentUsername;
      });

      // /tour/ API 호출하여 전체 여행 목록 가져오기
      final tourResponse = await dio.get(
        '$baseUrl/tour/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
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
        final nearest = userPlans.first;

        setState(() {
          _nearestPlan = {
            'id': nearest['id'],
            'title': nearest['tour_name'] ?? '제목 없음',
            'start_date': nearest['start_date'] ?? '',
            'end_date': nearest['end_date'] ?? '',
          };
          _isLoading = false;
        });
      } else {
        // 여행 계획이 없을 경우, userPlans가 비어있지 않으면 null로 설정
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
    final accessToken = await getAccessToken();
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';

    // 사용자 ID 불러오기
    final userResponse = await dio.get(
      '$baseUrl/user/me/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ),
    );

    final userId = userResponse.data['sub'];
    final uniqueCode = Random().nextInt(1 << 31); // 랜덤 정수 생성

    final channel = WebSocketChannel.connect(
      Uri.parse('ws://conever.duckdns.org:8000/tour/recommend/?user_id=$userId&areaCode=1&unique_code=$uniqueCode&days=1'),
    );

    late StreamSubscription subscription;

    subscription = channel.stream.listen((message) async {
      final data = jsonDecode(message);
      dynamic result = data["result"];

      // 응답 형식이 문자열이면 JSON 파싱 시도
      if (result is String) {
        try {
          result = jsonDecode(result);
        } catch (e) {
          return; // 파싱 실패 시 무시
        }
      }

      if (data["status"] != "SUCCESS" || result == null || result.isEmpty) return;

      // 이미지 있는 장소만 필터링
      final List<dynamic> flatPlaces = result.expand((course) {
        if (course is List) return course;
        return [];
      }).toList();
      final filteredPlaces = flatPlaces.where((place) => (place['image1'] ?? '').isNotEmpty).toList();

      if (filteredPlaces.isEmpty) return;

      final random = Random();
      final selectedPlace = filteredPlaces[random.nextInt(filteredPlaces.length)];

      try {
        await precacheImage(NetworkImage(selectedPlace['image1']), context);
      } catch (e) {
        print("이미지 프리캐싱 실패: $e");
      }

      if (mounted) {
        setState(() {
          _recommendedPlace = selectedPlace;
        });
      }

      await subscription.cancel();
      channel.sink.close();
    });
  }

  // AddPage_0에서 여행 생성 완료 후 전달된 tourId와 AddPage_2에서 선택한 장소 정보들을 함께 받아 서버에 POST 요청
  Future<void> saveTourCourse(int tourId, List<PlaceInfoBlock> places) async {
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';
    try {
      final accessToken = await getAccessToken();
      // 여행 시작일을 불러오기 위한 GET 요청
      final startDateResponse = await dio.get(
        '$baseUrl/tour/$tourId/',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );
      final startDate = startDateResponse.data['start_date'];

      // 장소 정보를 서버에 맞는 포맷으로 변환 (name, mapX, mapY, image, address)
      final List<Map<String, dynamic>> courseData = places.map((place) => {
        'name': '<${place.title}>',
        'mapX': place.mapX,
        'mapY': place.mapY,
        'image_url': place.imageUrl,
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
          'Authorization': 'Bearer $accessToken',
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              top: height * 0.1,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.066,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.024),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _currentUsername ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: width * 0.072,
                                  ),
                                ),
                                Text(
                                  '님',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: width * 0.05,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                                "오늘도 좋은 하루에요 👋",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.05,
                                )
                            ),
                            SizedBox(height: height * 0.024),
                            Text(
                              '⏰ 다가오는 일정',
                              style: TextStyle(
                                fontSize: width * 0.072,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: height * 0.012),
                            // ⬇️ PlanCard 위젯: 여행 카드의 크기를 반응형으로 지정, _nearestPlan에서 동적 데이터 사용
                            Center(
                              child: _isLoading
                                  ? Container(
                                      width: width * 0.8,
                                      height: height * 0.394,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    )
                                  : (
                                      _nearestPlan != null
                                          ? PlanCard(
                                              tour_id: _nearestPlan!['id'],
                                              title: _nearestPlan!['title'] ?? '제목 없음',
                                              startDate: _nearestPlan!['start_date'] ?? '',
                                              endDate: _nearestPlan!['end_date'] ?? '',
                                              size_h: height * 0.394,
                                              size_w: width * 0.8,
                                            )
                                          : SizedBox.shrink()
                                    ),
                            ),
                            SizedBox(height: height * 0.06),
                            Center(
                              child: ProceedButton(
                                size_w: width * 0.586,
                                size_h: height * 0.055,
                                text: "✨새로운 장소 탐험하기",
                                fontSize_: width * 0.04,
                                fontWeight_: FontWeight.w900,
                                onTap: _scrollToBottom,
                              ),
                            ),
                            // 트렌딩 버튼 하단에 여백 추가
                            SizedBox(height: height * 0.09),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                              child: Text(
                                "오늘\n이런 곳은 어떤가요?",
                                style: TextStyle(
                                  fontSize: width * 0.0748,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.04),
                            // 장소 추천 영역: 단일 Column으로 조건부 children 렌더링
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_recommendedPlace != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      _recommendedPlace!['image1'],
                                      width: width * 0.87,
                                      height: width * 0.55,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: width * 0.045, color: Colors.black),
                                      SizedBox(width: width * 0.013),
                                      Text(
                                        _recommendedPlace!['title'],
                                        style: TextStyle(
                                          fontSize: width * 0.037,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.007),
                                  Text(
                                    (_recommendedPlace?['title'] != null && _recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                                        ? "${_recommendedPlace?['title']}은(는) ${(_recommendedPlace?['address'] as String).split(' ')[1]}의 관광지 입니다.\n${_currentUsername ?? ''} 님의 마음에 드셨으면 좋겠네요!"
                                        : '',
                                    style: TextStyle(
                                      fontSize: width * 0.03,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: height * 0.017),
                                  Center(
                                    child: ProceedButton(
                                      size_w: width * 0.5,
                                      size_h: height * 0.05,
                                      text: (_recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                                          ? "${(_recommendedPlace?['address'] as String).split(' ')[1]} 코스 생성하기"
                                          : "코스 생성하기",
                                      fontSize_: width * 0.032,
                                      fontWeight_: FontWeight.bold,
                                      onTap: () async {
                                        final String sigun = (_recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                                            ? (_recommendedPlace?['address'] as String).split(' ')[1]
                                            : '';
                                        final accessToken = await getAccessToken();
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (_) => AddPage_2(
                                              title: sigun,
                                              tourId: 0,
                                              isSingleDayMode: true, // 싱글모드 명시 -> 트렌딩, 검색창일 경우 true
                                              onSaveCourseCallback: (places) {
                                                Navigator.of(context).push(
                                                  CupertinoPageRoute(
                                                    builder: (_) => AddPage_0(
                                                      onFinishCreation: (int tourId) {
                                                        Navigator.of(context).push(
                                                          CupertinoPageRoute(
                                                            builder: (_) => AddPage_3(
                                                              tour_id: tourId,
                                                            ),
                                                          ),
                                                        );
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
                                ] else ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: width * 0.87,
                                      height: width * 0.55,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Container(
                                    width: width * 0.87,
                                    height: height * 0.08,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.04,
                                      vertical: height * 0.012,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '트렌딩 페이지 정보를 받아오고 있습니다...',
                                        style: TextStyle(
                                          fontSize: width * 0.032,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.017),
                                  Center(
                                    child: ProceedButton(
                                      size_w: width * 0.5,
                                      size_h: height * 0.05,
                                      text: '가져오는 중...',
                                      fontSize_: width * 0.032,
                                      fontWeight_: FontWeight.bold,
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            SizedBox(height: height * 0.01),

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
                                  size: width * 0.06,
                                ),
                                label: Text(
                                  '홈으로 이동',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: width * 0.025,
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
                            SizedBox(height: height * 0.092),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 행정구역 검색 기능을 제공하는 앱바, 오버레이 리스트와 연결됨
            SearchAppBar(
              onSaveCourse: saveTourCourse,
            ),
          ],
        ),
      ),
    );
  }
}

