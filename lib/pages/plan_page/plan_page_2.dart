import 'package:alpha_fe/components/token_controller.dart';
import 'package:alpha_fe/main.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/components/plan_card.dart';
import 'package:alpha_fe/components/plan_edit.dart';
import 'package:alpha_fe/components/plan_course_event.dart';
import 'package:alpha_fe/pages/plan_page/add_user.dart';

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
      appBar: const DefaultAppBar(title: "계획보기 앱바 영역"),
      body: plan_page2_body(
        tour_id: widget.tour_id,
        onDataRefreshed: _onDataRefreshed,
      ),
    );
  }
}

class plan_page2_body extends StatefulWidget {
  final int tour_id;
  final VoidCallback? onDataRefreshed;
  // Since widget.showaddbutton is a final variable, update logic should be managed with a separate state variable.
  // Add a state variable:
  // bool showAddButton = false; // This will be in State, not Widget.

  const plan_page2_body({
    Key? key,
    required this.tour_id,
    this.onDataRefreshed,
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
  Future<String?> get accessToken async => await getAccessToken();
  String get dateRange => "$startDate ~ $endDate";

  List<Map<String, dynamic>> courseData = [];
  bool _isLoading = true;

  //여행 경로 가져오기 api
  Future<void> fetchTourCourse() async {
    final dio = Dio();
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
      print("코스 불러오기 실패: $e");
    }
  }

  //내 여행 가져오기(하나만) - 제목,날짜,동행자 정보 가져오기
  Future<void> fetchTourName() async {
    final dio = Dio();
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
    Future.wait([
      fetchTourCourse(),
      fetchTourName(),
    ]).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

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
    return WillPopScope(
      onWillPop: () async => true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
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
                          Expanded(child: Plan_Name()),
                          IconButton(
                            icon: Icon(Icons.edit, size: MediaQuery.of(context).size.width * 0.07),
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: TravelEditMenu(
                                    startDate: startDate,
                                    endDate: endDate,
                                    tour_id: widget.tour_id,
                                    tourName: tourName,
                                    onRefresh: _refreshData,
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
                      Traveler_List(),
                      DashedLine(),
                      travel_plan(
                        tour_id: widget.tour_id,
                        courseData: courseData,
                        onRefresh: _refreshData,
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
  const Plan_Name({super.key});


  @override
  Widget build(BuildContext context) {
    final remainingDays = calculateRemainingDays(
      context.findAncestorStateOfType<_plan_page2_bodyState>()?.endDate ?? "",
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.025,0,0,0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.red[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
            ),
            // margin: const EdgeInsets.all(5),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.height * 0.0025),
              child: Text(
                "D-$remainingDays", //이거 디데이 인자로 바꿀예정
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.02,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.0075, 0, 0, 0),
            child: Text(
              context.findAncestorStateOfType<_plan_page2_bodyState>()?.tourName ?? "",
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.07, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.0075, 0, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: MediaQuery.of(context).size.width * 0.035, color: Colors.grey),
                SizedBox(width: MediaQuery.of(context).size.width * 0.0125),
                Text(
                  context.findAncestorStateOfType<_plan_page2_bodyState>()?.dateRange ?? "",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.032, color: Colors.grey),
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
    final parentState = context.findAncestorStateOfType<_plan_page2_bodyState>();
    final travelers = parentState?.travelers ?? [];

    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Text(
            "여행자",
            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          SizedBox(
            child: Wrap(
              spacing: MediaQuery.of(context).size.width * 0.04,
              runSpacing: MediaQuery.of(context).size.height * 0.01,
              children: [
                ...travelers.map((traveler) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.06,
                      backgroundImage: NetworkImage(traveler["imageUrl"]!),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.002),
                    SizedBox(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          traveler["name"]!,
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
                        ),
                      ),
                    ),
                  ],
                )),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileListPage(
                          tour_id: parentState!.widget.tour_id,
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
                        radius: MediaQuery.of(context).size.width * 0.06,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.add, color: Colors.grey, size: MediaQuery.of(context).size.width * 0.05),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.002),
                      SizedBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "초대",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
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
    return LayoutBuilder(
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
    );
  }
}

