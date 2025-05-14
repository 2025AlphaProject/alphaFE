import 'dart:async';
import 'package:alpha_fe/pages/home_page/home_page_view_model/save_tour_course_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../components/app_bar.dart';
import '../../components/plan_card.dart'; // 여행 계획 카드 컴포넌트
import '../../components/placeinfo_card.dart';
import '../../components/proceed_button.dart'; // 버튼 컴포넌트
import '../add_page/add_page_0/add_page_0.dart';
import '../add_page/add_page_2.dart';
import '../add_page/add_page_3.dart';
import 'home_page_view_model/plan_view_model.dart';
import 'home_page_view_model/recommend_place_view_model.dart';

class HomePage extends StatefulWidget {
  final String? accessToken;
  const HomePage({super.key, required this.accessToken});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlanViewModel>(context, listen: false).fetchPlans(context);
      Provider.of<RecommendPlaceViewModel>(context, listen: false).fetchRecommendation(context);
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // AddPage_0에서 여행 생성 완료 후 전달된 tourId와 AddPage_2에서 선택한 장소 정보들을 함께 받아 서버에 POST 요청
  Future<void> saveTourCourse(int tourId, List<PlaceInfoBlock> places) async {
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';
    try {
      final accessToken = widget.accessToken;

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
      }
      else {
        print('저장 실패: ${response.statusCode}');
      }
    }
    catch (e) {
      print('예외 발생: $e');
    }
  }

  // PlanCard와 동일 크기의 빈 카드 UI, 탭 시 새 여행 생성 페이지로 이동
  Widget _buildEmptyPlanCard(double width, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => AddPage_0(accessToken: widget.accessToken,),
          ),
        );
      },
      child: Container(
        width: width * 0.8,
        height: height * 0.394,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 37.5, color: Color(0xFFB5B5B5),),
              SizedBox(height: height * 0.01),
              const Text(
                '이런, 여행이 없어요🧐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB5B5B5),
                ),
              ),
              const Text(
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

  @override
  Widget build(BuildContext context) {
    final recommendedPlace = context.watch<RecommendPlaceViewModel>().recommendedPlace;
    final username = context.watch<PlanViewModel>().currentUsername;
    final nearestPlan = context.watch<PlanViewModel>().nearestPlan;
    final isLoading = context.watch<PlanViewModel>().isLoading;
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                                  username ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 28,
                                  ),
                                ),
                                const Text(
                                  '님',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                                "오늘도 좋은 하루에요 👋",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                )
                            ),
                            SizedBox(height: height * 0.024),
                            const Text(
                              '⏰ 다가오는 일정',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: height * 0.012),
                            // ⬇️ PlanCard 위젯: 여행 카드의 크기를 반응형으로 지정, _nearestPlan에서 동적 데이터 사용
                            Center(
                              // 로딩 중에는 PlanCard와 동일한 디자인의 빈 카드 표시
                              child: isLoading
                                  ? // 로딩 플레이스홀더
                              SizedBox(
                                width: width * 0.8,
                                height: height * 0.394,
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  color: const Color(0xFFF5F5F5),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      width * 0.05,
                                      height * 0.05,
                                      width * 0.05,
                                      height * 0.05,
                                    ),
                                  ),
                                ),
                              )
                                  : (
                                      nearestPlan != null
                                          ? PlanCard(
                                              title: nearestPlan['title']!,
                                              startDate: nearestPlan['start_date']!,
                                              endDate: nearestPlan['end_date']!,
                                              size_h: height * 0.394,
                                              size_w: width * 0.8,
                                              tour_id: nearestPlan['id']!,
                                              accessToken: widget.accessToken,
                                            )
                                          : _buildEmptyPlanCard(width, height)
                                    ),
                            ),
                            SizedBox(height: height * 0.06),
                            Center(
                              child: ProceedButton(
                                size_w: width * 0.586,
                                size_h: height * 0.055,
                                text: "✨ 새로운 장소 탐험하기",
                                fontSize_: 15,
                                fontWeight_: FontWeight.bold,
                                onTap: _scrollToBottom,
                              ),
                            ),
                            // 트렌딩 버튼 하단에 여백 추가
                            SizedBox(height: height * 0.11),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                              child: const Text(
                                "오늘\n이런 곳은 어떤가요?",
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.04),
                            // 장소 추천 영역: 단일 Column으로 조건부 children 렌더링
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          if (recommendedPlace != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: recommendedPlace['image1'] != 'ERROR'
                                        ? Image.network(
                                            recommendedPlace['image1'],
                                            width: width * 0.87,
                                            height: height * 0.25,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: width * 0.87,
                                                height: height * 0.25,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: width * 0.093,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            width: width * 0.87,
                                            height: height * 0.25,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: width * 0.093,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 17, color: Colors.black),
                                      SizedBox(width: width * 0.013),
                                      Text(
                                        recommendedPlace['title'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.007),
                                  Padding(
                                    padding: EdgeInsets.only(left: width * 0.053),
                                    child: Text(
                                      (recommendedPlace['title'] != null && recommendedPlace['address'] != null && (recommendedPlace['address'] as String).split(' ').length > 1)
                                          ? "${recommendedPlace['title']}은(는) ${(recommendedPlace['address'] as String).split(' ')[1]}의 관광지 입니다.\n${_currentUsername ?? ''} 님의 마음에 드셨으면 좋겠네요!"
                                          : '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.017),
                                  Center(
                                    child: ProceedButton(
                                      size_w: width * 0.5,
                                      size_h: height * 0.05,
                                      text: (recommendedPlace['address'] != null && (recommendedPlace['address'] as String).split(' ').length > 1)
                                          ? "${(recommendedPlace['address'] as String).split(' ')[1]} 코스 생성하기"
                                          : "코스 생성하기",
                                      fontSize_: 13,
                                      fontWeight_: FontWeight.bold,
                                      onTap: () async {
                                        final String sigun = (recommendedPlace['address'] != null && (recommendedPlace['address'] as String).split(' ').length > 1)
                                            ? (recommendedPlace['address'] as String).split(' ')[1]
                                            : '';
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
                                                              tour_id: tourId, accessToken: widget.accessToken,
                                                            ),
                                                          ),
                                                        );
                                                        context.read<TourCourseViewModel>().save(context, tourId, places);
                                                      }, accessToken: widget.accessToken,
                                                    ),
                                                  ),
                                                );
                                              }, accessToken: widget.accessToken,
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
                                      height: height * 0.25,
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
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '트렌딩 페이지 정보를 받아오고 있습니다...',
                                        style: TextStyle(
                                          fontSize: 13,
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
                                      fontSize_: 13,
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
                                label: const Text(
                                  '홈으로 이동',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.2,
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
                            SizedBox(height: height * 0.12),
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
              onSaveCourse: saveTourCourse, accessToken: widget.accessToken,
            ),
          ],
        ),
      ),
    );
  }
}