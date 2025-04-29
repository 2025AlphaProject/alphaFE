import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "계획보기 앱바 영역"),
      body: plan_page2_body(tour_id: widget.tour_id),
    );
  }
}

class plan_page2_body extends StatefulWidget {
  final int tour_id;

  const plan_page2_body({Key? key, required this.tour_id}) : super(key: key);

  @override
  State<plan_page2_body> createState() => _plan_page2_bodyState();
}

class _plan_page2_bodyState extends State<plan_page2_body> {
  String tourName = "";
  String startDate = "";
  String endDate = "";
  String userName = "";
  String userProfileImageUrl = "";
  List<Map<String, String>> travelers = [];
  final TextEditingController _textController = TextEditingController();
  final String accessToken =  dotenv.env['KAKAO_ACCESS_TOKEN']!;
  String get dateRange => "$startDate ~ $endDate";

  List<Map<String, dynamic>> courseData = [];

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
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          setState(() {
            courseData = data.map<Map<String, dynamic>>((day) {
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
      }
    } catch (e) {
      print("코스 불러오기 실패: $e");
    }
  }

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
  Future<void> fetchTourEdit() async {
    final dio = Dio();
    try{
      final response = await dio.post(
        'http://conever.duckdns.org:8000/tour/${widget.tour_id}/',
        data: {

        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      if(response.statusCode == 200){
        print("수정 완료: ${response.data}");
      }
    } catch(e){

    }
  }

  @override
  void initState() {
    super.initState();
    fetchTourCourse();
    fetchTourName();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Memo(controller: _textController),//이안에 메모랑 여행정보 있음
                SizedBox(width: 10,),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      builder: (context) => TravelEditMenu(
                        startDate: startDate,
                        endDate: endDate,
                        tour_id: widget.tour_id,
                        tourName: tourName,
                      ),
                    );
                  },
                ),
              ],
            ),
            Traveler_List(),//동행자들
            DashedLine(),
            travel_plan(courseData: courseData),
          ],
        ),
      ),
    );
  }
}


//메모 관련 코드 아직 수정이 필요함
class Memo extends StatefulWidget {
  final TextEditingController controller;

  const Memo({Key? key, required this.controller}) : super(key: key);

  @override
  State<Memo> createState() => _MemoState();
}

class _MemoState extends State<Memo> {
  bool _showInput = false; // 입력창 표시 여부

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 버튼
        TextButton(
          onPressed: () {
            setState(() {
              _showInput = !_showInput; // 입력창 표시 상태 토글
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.settings, size: 10,color: Color(0xFFB5B5B5),),
              SizedBox(width: 5,),
              Text(_showInput ? "메모 수정완료" : "메모",
                style: TextStyle(fontSize: 10,color: Color(0xFFB5B5B5)),
              ),
            ],
          ),
        ),
        Plan_Name(),
        const SizedBox(height: 12),

        // 입력창
        if (_showInput)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: SizedBox(
              width: 300,
              height: 28,
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  labelText: "메모를 입력하세요",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 12, color: Color(0xFFB5B5B5)),

                ),
              ),
            ),
          ),
      ],
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
      padding: const EdgeInsets.fromLTRB(8,0,0,0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.red[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            // margin: const EdgeInsets.all(5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 1),
              child: Text(
                "D-$remainingDays", //이거 디데이 인자로 바꿀예정
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
            child: Text(
              context.findAncestorStateOfType<_plan_page2_bodyState>()?.tourName ?? "",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  context.findAncestorStateOfType<_plan_page2_bodyState>()?.dateRange ?? "",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "여행자",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...travelers.map((traveler) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(traveler["imageUrl"]!),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          traveler["name"]!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )),
                  // ➕ 초대 버튼
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileListPage(tour_id: parentState!.widget.tour_id),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.add, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        const Text("초대", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


//점선 구분선
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
