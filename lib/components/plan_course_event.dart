import 'package:alpha_fe/pages/plan_page/near_event.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/pages/plan_page/near_event.dart';

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
          final date = day['date'] ?? '';
          final places = day['places'] as List<dynamic>? ?? [];
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
                  roadAddress: place['road_address'] ?? '',
                  numberAddress: place['parcel_address'] ?? '',
                  mapX: place['mapX']?? '',
                  mapY: place['mapY']?? '',
                );
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }
}

//장소별 정보 위젯
class place_card extends StatelessWidget {
  final String imageUrl;
  final String placeName;
  final String roadAddress;
  final String numberAddress;
  final double mapX;
  final double mapY;

  const place_card({super.key,
    required this.imageUrl,
    required this.placeName,
    required this.roadAddress,
    required this.numberAddress,
    required this.mapX,
    required this.mapY,
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
          Events(mapX: mapX, mapY: mapY),
        ],
      ),
    );
  }
}


//장소별 문화행사
class Events extends StatefulWidget {
  final double mapX;
  final double mapY;

  const Events({super.key,
    required this.mapX,
    required this.mapY
  });

  @override
  State<Events> createState() => _EventsState();
}
//이부분 리스트 받아오는거 수정해야지
class _EventsState extends State<Events> {
  bool _isExpanded = false;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  // 장소 주변 행사정보 가져오기
  Future<void> fetchEvents() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'http://conever.duckdns.org:8000/tour/near_event/',
        queryParameters: {
          'mapX': widget.mapX,
          'mapY': widget.mapY,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          events = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {  //TODO: 오류뜰때 어케할지 수정해야함
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔽 드롭다운 버튼 - 문화행사정보 숨기기용
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            children: [
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons
                    .keyboard_arrow_down,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                _isExpanded ? "주변 행사 닫기" : "주변 행사 보기",
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
          firstChild: events.isEmpty
              ? Row( //주변행사가 없을때
                  children: [
                    SizedBox(width: 10,),
                    const Text(
                      "주변 행사가 없습니다.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              : Wrap( //주변행사 있을때
                  spacing: 12,
                  runSpacing: 12,
                  children: events.map((event) {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => nearEvents(eventData: event), //행사정보 상세페이지로 이동
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                      child: Column( //경로 페이지에서는 행사유형과 이름만 표시
                        children: [
                          Text(
                            event['category'],
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            event['title'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
