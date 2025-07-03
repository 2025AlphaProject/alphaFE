import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../components/app_bar.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/components/plan_edit.dart';
import 'package:alpha_fe/components/plan_course_event.dart';
import 'package:alpha_fe/pages/plan_page/add_user/add_user.dart';
import 'package:alpha_fe/components/plan_loading_page.dart';

import '../../../components/logout_by_expiration.dart';
import '../../../services/access_token/get_access_token_from_refresh_token.dart';

class PlanPage2 extends StatefulWidget {
  final int tour_id;
  const PlanPage2({Key? key, required this.tour_id}) : super(key: key);

  @override
  State<PlanPage2> createState() => _PlanPage2State();
}

class _PlanPage2State extends State<PlanPage2> {
  void _onDataRefreshed() {
    print('Data refreshed in PlanPage2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "나의 계획"),
      body: plan_page2_body(
        tour_id: widget.tour_id,
        onDataRefreshed: _onDataRefreshed,
        accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzUwOTQ2NzE2LCJpYXQiOjE3NTA5NDMxMTYsImp0aSI6IjU5ZjEzY2E3OTUzZjQ1ZjdiNzVjZTVmMDdhY2QyNDc3Iiwic3ViIjo0MjQ3MDU2NzY2fQ.zaFLoabaEpdIc61GjmHdRHJhH4nCai9YpkOhvF6Zra0",
      ),
    );
  }
}

class plan_page2_body extends StatefulWidget {
  final String? accessToken;
  final int tour_id;
  final VoidCallback? onDataRefreshed;
  // Since widget.showaddbutton is a final variable, update logic should be managed with a separate state variable.
  // Add a state variable:
  // bool showAddButton = false; // This will be in State, not Widget.

  const plan_page2_body({
    Key? key,
    required this.tour_id,
    this.onDataRefreshed,
    required this.accessToken,
  }) : super(key: key);

  @override
  State<plan_page2_body> createState() => _plan_page2_bodyState();
}

class _plan_page2_bodyState extends State<plan_page2_body> {
  bool showEditButton = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String tourName = "";
  String startDate = "";
  String endDate = "";
  String userName = "";
  String userProfileImageUrl = "";
  List<Map<String, String>> travelers = [];
  final TextEditingController _textController = TextEditingController();


  List<Map<String, dynamic>> courseData = [];
  bool _isLoading = true;

  //여행 경로 가져오기 api
  Future<void> fetchTourCourse() async {
    final dio = Dio();
    final accessToken = widget.accessToken;
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/tour/course/${widget.tour_id}/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) { //응답제대로 됬을때
        final tourResponse = response;
        final List<dynamic> allPlans = tourResponse.data is List ? tourResponse.data : [];
        // 디버깅 출력 코드 추가
        print("코스 데이터 이미지 URL 목록:");
        for (final day in allPlans) {
          for (final place in day['places']) {
            print(" - ${place['image_url']}");
          }
        }
        setState(() {
          courseData = allPlans.map<Map<String, dynamic>>((day) {
            final date = day['date'] ?? '';
            final places = (day['places'] as List<dynamic>? ?? []).map<Map<String, dynamic>>((place) {
              return {
                'name': place['name'] ?? '',
                'mapX': place['mapX'] != null ? place['mapX'].toDouble() : 0.0,
                'mapY': place['mapY'] != null ? place['mapY'].toDouble() : 0.0,
                'image_url': place['image_url'] ?? '',
                'road_address': place['road_address'] ?? '',
                'parcel_address': place['parcel_address'] ?? '',
              };
            }).toList();
            return {
              'date': date,
              'places': places,
            };
          }).toList();
        });
      }
    } catch (e) {

      // 엑세스 토큰 만료 시 리프레시 토큰을 사용해 재발급
      if (e is DioException && e.response?.statusCode == 403) {
        final bool? result = await getAccessTokenFromRefreshToken();
        if (result == false) {
          LogoutByExpiration(context);
        }
        await fetchTourCourse();
        return;
      }
      print("코스 불러오기 실패: $e");
    }
  }

  //내 여행 가져오기(하나만) - 제목,날짜,동행자 정보 가져오기
  Future<void> fetchTourName() async {
    final dio = Dio();
    final accessToken = widget.accessToken;
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/tour/${widget.tour_id}/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final tourinfo = response.data;
        setState(() {
          tourName = tourinfo['tour_name'] ?? "";
          startDate = tourinfo['start_date'] ?? "";
          endDate = tourinfo['end_date'] ?? "";
          if (tourinfo['user'] != null && tourinfo['user'] is List) {
            travelers = (tourinfo['user'] as List).map<Map<String, String>>((user) {
              return {
                'name': user['username'] ?? '이름없음',
                'imageUrl': user['profile_image_url'] ?? 'https://via.placeholder.com/150',
              };
            }).toList();
          }
        });
      }
    } catch (e) {
      print("여행 불러오기 실패: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // 초기 데이터 로딩 및 이미지 프리캐시 처리
  Future<void> _loadInitialData() async {
    await fetchTourCourse(); // 먼저 코스 정보만 불러옴

    // 이미지 URL 목록 수집
    final imageUrls = courseData
        .expand((day) => day['places'] as List<Map<String, dynamic>>)
        .map((place) => place['image_url'] as String)
        .where((url) => url.isNotEmpty)
        .toList();

    // 이미지 프리캐싱
    for (final url in imageUrls) {
      if (!mounted) return;
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (e) {
        print("프리캐싱 실패: $e");
      }
    }

    // 프리캐싱까지 완료 후 이름/날짜 등 정보 불러오기
    await fetchTourName();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _refreshData();
  //   });
  // }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([
      fetchTourCourse(),
      fetchTourName(),
    ]);
    setState(() {
      _isLoading = false;
    });
    if (widget.onDataRefreshed != null) {
      widget.onDataRefreshed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return WillPopScope(
      onWillPop: () async => true,
      child: _isLoading
          ? const PlanLoadingView() // 이미지가 로딩 중일 때 로딩 페이지 표시
          : Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Plan_Name(startDate: startDate,
                            endDate: endDate,tourName: tourName,)),
                          IconButton(
                            icon: Icon(Icons.edit, size: width * 0.07),
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => Center(
                                  child: SizedBox(
                                    width: kIsWeb ? width * 0.95: null,
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: const Color(0xFFF5F5F5),
                                      elevation: 10,
                                      contentPadding: EdgeInsets.zero,
                                      content: TravelEditMenu(
                                        startDate: startDate,
                                        endDate: endDate,
                                        tour_id: widget.tour_id,
                                        tourName: tourName,
                                        onRefresh: _refreshData,
                                        accessToken: widget.accessToken,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              if (result == true) {
                                await _refreshData(); // Refresh data after dialog is popped with result true
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.005),
                      const Traveler_List(),
                      SizedBox(height: height * 0.02),
                      const DashedLine(),
                      travel_plan(
                        tour_id: widget.tour_id,
                        courseData: courseData,
                        onRefresh: _refreshData,
                        accessToken: widget.accessToken,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}


//여행 디데이 및 여행명
class Plan_Name extends StatelessWidget {
  final String startDate;
  final String endDate;
  final String tourName;
  const Plan_Name({super.key, required this.startDate, required this.endDate, required this.tourName});

  // 날짜 기준으로만 계산, 진행중 - 종료 로직 추가
  String getRemainingStatus(String startDate, String endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);

    if (today.isAfter(endOnly.add(Duration(days: 1)))) return '종료';
    if (!today.isBefore(startOnly)) return '진행중';

    final remaining = startOnly.difference(today).inDays;
    return 'D-$remaining';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final statusText = getRemainingStatus(startDate, endDate);

    return Padding(
      padding: EdgeInsets.only(left: width * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.red[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.01),
            ),
            // margin: const EdgeInsets.all(5),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.0025),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.0075),
            child: Text(
              tourName,
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.0075),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 14.3, color: Colors.grey),
                SizedBox(width: width * 0.0125),
                Text(
                  "$startDate ~ $endDate",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// 동행자들
class Traveler_List extends StatelessWidget {
  const Traveler_List({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final parentState = context.findAncestorStateOfType<_plan_page2_bodyState>();
    final travelers = parentState?.travelers ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: 0.0115),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.01),
          const Text(
            "여행자",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: height * 0.012),
          SizedBox(
            child: Wrap(
              spacing: width * 0.04,
              runSpacing: height * 0.01,
              children: [
                ...travelers.map((traveler) {
                  final rawUrl = traveler["imageUrl"]!;
                  final imageUrl = kIsWeb
                      ? 'https://images.weserv.nl/?url=${rawUrl.replaceFirst('http://', '')}'
                      : rawUrl;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: width * 0.06,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                      SizedBox(height: height * 0.002),
                      SizedBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            traveler["name"]!,
                            style: const TextStyle(fontSize: 14.3),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileListPage(
                          tour_id: parentState!.widget.tour_id,
                          accessToken: parentState.widget.accessToken,
                        ),
                      ),
                    ).then((_) {
                      parentState?._refreshData();
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: width * 0.06,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.add, color: Colors.grey, size: width * 0.05),
                      ),
                      SizedBox(height: height * 0.002),
                      const SizedBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "초대",
                            style: TextStyle(fontSize: 14.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


//점선 구분선 - 이건 디자인용
class DashedLine extends StatelessWidget {
  final Axis axis; // 가로 or 세로 방향
  final double length;
  final double dashLength;
  final double dashGap;
  final Color color;
  final double thickness;

  const DashedLine({
    super.key,
    this.axis = Axis.horizontal,
    this.length = double.infinity,
    this.dashLength = 5,
    this.dashGap = 3,
    this.color = Colors.grey,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(width * 0.04, 0, width * 0.04, height * 0.03),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = axis == Axis.horizontal
              ? constraints.maxWidth
              : constraints.maxHeight;

          final dashCount = (size / (dashLength + dashGap)).floor();

          return Flex(
            direction: axis,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: axis == Axis.horizontal ? dashLength : thickness,
                height: axis == Axis.horizontal ? thickness : dashLength,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

