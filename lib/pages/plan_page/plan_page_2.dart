import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/components/plan_card.dart';
import 'package:alpha_fe/pages/plan_page/plan_edit_date.dart';

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
  final TextEditingController _textController = TextEditingController();
  String accessToken = ""; //TODO: 카카오 액세스 토큰 연결
  String get dateRange => "$startDate ~ $endDate";

  List<Map<String, dynamic>> courseData = [];

  Future<void> fetchTourCourse() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        'http://localhost:8000/tour/course/${widget.tour_id}/',
      );
      if (response.statusCode == 200) {
        setState(() {
          courseData = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      print("코스 불러오기 실패: $e");
    }
  }

  Future<void> fetchTourName() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        'http://localhost:8000/tour/${widget.tour_id}/',
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
        'http://localhost:8000/tour/${widget.tour_id}/',
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


// 전체적인 편집관련
class TravelEditMenu extends StatelessWidget {
  final String startDate;
  final String endDate;
  final int tour_id;
  final String tourName;

  const TravelEditMenu({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.tour_id,
    required this.tourName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("편집", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _EditMenu(
              text: "여행계획 수정",
              onTap: () {},
            ),
            _EditMenu(
              text: "여행제목 수정",
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController _nameController = TextEditingController(text: tourName);
                    return AlertDialog(
                      title: const Text("여행제목 수정"),
                      content: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: "새 여행제목 입력",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // 취소
                          },
                          child: const Text("취소"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: 서버로 수정된 제목 전송 추가 가능
                            Navigator.pop(context);
                          },
                          child: const Text("확인"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            _EditMenu(
              text: "여행날짜 수정",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => planEditDate(
                      startDate: startDate,
                      endDate: endDate,
                      tour_id: tour_id,
                    ),
                  ),
                );
              },
            ),
            _EditMenu(
              text: "여행 삭제",
              isDestructive: true,
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 단일 편집메뉴
class _EditMenu extends StatelessWidget {
  final String text;
  final bool isDestructive;
  final VoidCallback onTap;

  const _EditMenu({
    super.key,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // 선택 후 닫기
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isDestructive ? Colors.red : Colors.black,
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
                "$remainingDays", //이거 디데이 인자로 바꿀예정
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


//동행자들
class Traveler_List extends StatefulWidget {
  const Traveler_List({Key? key}) : super(key: key);

  @override
  State<Traveler_List> createState() => _Traveler_ListState();
}

class _Traveler_ListState extends State<Traveler_List> {
  List<Map<String, String>> travelers = [
    {
      "name": "이영욱",
      "imageUrl": 'https://avatars.githubusercontent.com/u/46028234?v=4',
    },
    {
      "name": "조시연",
      "imageUrl": 'https://avatars.githubusercontent.com/u/46028234?v=4',
    },
    {
      "name": "신윤솔",
      "imageUrl": 'https://avatars.githubusercontent.com/u/46028234?v=4',
    },
  ];

  void _inviteTraveler() {
    setState(() {
      travelers.add({
        "name": "새 여행자",
        "imageUrl": "assets/images/new_user.png",
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          backgroundImage:
                          NetworkImage(traveler["imageUrl"]!),
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
                    onTap: _inviteTraveler,
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


//여행 코스
class travel_plan extends StatelessWidget {
  final List<Map<String, dynamic>> courseData;

  const travel_plan({super.key, required this.courseData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text("🧭 예정된 코스"),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: (){},
              ),
            ],
          ),
        ),
        ...courseData.map((day) {
          final date = day['date'];
          final places = day['places'] as List<dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text("📅 $date", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...places.map((place) {
                return place_card(
                  imageUrl: place['image_url'] ?? '',
                  placeName: place['name'] ?? '',
                  roadAddress: place['mapX'] ?? '',
                  numberAddress: place['mapY'] ?? '',
                );
              }).toList()
            ],
          );
        }).toList(),
      ],
    );
  }
}


//장소별
class place_card extends StatelessWidget {
  final String imageUrl;
  final String placeName;
  final String roadAddress;
  final String numberAddress;

  const place_card({super.key,
    required this.imageUrl,
    required this.placeName,
    required this.roadAddress,
    required this.numberAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  width: 130,
                  height: 110,
                ),
              ),
              Column(
                children: [
                  Row( //여행명
                    children: [
                      Icon(Icons.pin_drop),
                      Text(placeName),
                    ],
                  ),
                  Row( //주소
                    children: [
                      Icon(Icons.home),
                      Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  child: Text("도로명"),
                                ),
                                Text(roadAddress) //여기 바꿔야함
                              ],
                            ),
                            Row( //지번
                              children: [
                                SizedBox(
                                  child: Text("지번"),
                                ),
                                Text(numberAddress) //여기 바꿔야함
                              ],
                            ),
                          ]
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Events(
            events: [
              {
                "title": "예술의 전당 공연",
                "icon": "🎭",
                "price": "유료",
              },
              {
                "title": "시민 야외 콘서트",
                "icon": "🎶",
                "price": "무료",
              },
            ],
          ),
        ],
      ),
    );
  }
}


//장소별 문화행사
class Events extends StatefulWidget {
  final List<Map<String, String>> events;
  const Events({super.key, required this.events});

  @override
  State<Events> createState() => _EventsState();
}
//이부분 리스트 받아오는거 수정해야지
class _EventsState extends State<Events> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔽 드롭다운 버튼
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            children: [
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                _isExpanded ? "추가된 행사 닫기" : "추가된 행사 보기",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 🔳 카드 목록 (보일 때만)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.events.map((event) {
              return Container(
                width: 150,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(event['icon']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 8),
                    Text(
                      event['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event['price'] == "무료" ? "🆓 무료" : "💰 유료",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

