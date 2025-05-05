import 'package:alpha_fe/pages/plan_page/near_event.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/components/plan_edit.dart';
import 'package:alpha_fe/pages/plan_page/plan_page.dart';
import 'package:alpha_fe/pages/plan_page/plan_page_2.dart';

import 'date_dropdown.dart';
//여행 코스

class travel_plan extends StatelessWidget {
  final List<Map<String, dynamic>> courseData;
  final int tour_id;
  final VoidCallback? onRefresh;

  const travel_plan({super.key, required this.courseData, required this.tour_id, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // --- Date filter state ---
    final selectedDate = ValueNotifier<String?>(null);
    final dates = courseData.map((e) => e['date'] as String).toSet().toList()..sort();
    // -------------------------
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.032),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.0222, vertical: height * 0.011),
            child:
                Text("🧭 예정된 코스",style: TextStyle(fontSize:width * 0.06, fontWeight: FontWeight.w800),),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: selectedDate,
            builder: (context, value, _) {
              final filtered = value == null
                  ? courseData
                  : courseData.where((d) => d['date'] == value).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dates.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.022, vertical: height * 0.011),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DateDropdown(
                              dates: dates,
                              selectedDate: selectedDate,
                              width: width,
                              height: height,
                            ),
                          ),
                          SizedBox(width: width * 0.03), // Add spacing between dropdown and button
                          if (EditState.showEditButton)
                            ElevatedButton(
                              onPressed: () {
                                EditState.showEditButton = false;
                                onRefresh?.call();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: width * 0.033, vertical: height * 0.011),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: const Color(0xFFF9F9F9),
                                foregroundColor: Colors.black,
                              ),
                              child: Text("취소", style: TextStyle(fontSize: width * 0.04)),
                            ),
                        ],
                      ),
                    ),
                  ...filtered.map((day) {
                    final date = day['date'] ?? '';
                    final places = day['places'] as List<dynamic>? ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.022, vertical: height * 0.011),
                          child: Row(
                            children: [
                              Text(
                                "📅 $date",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.044,
                                ),
                              ),
                              SizedBox(width: width * 0.03,),
                              if (EditState.showEditButton)
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final result = await showDialog(
                                          context: context,
                                          builder: (context) => Center(child: DeleteCourse(tour_id: tour_id, target_date: date,onRefresh: onRefresh,)),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.033,
                                          vertical: height * 0.011,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text("삭제",style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold),),
                                    ),
                                  ],
                                ),
                            ],
                          ),
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
                  if (filtered.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.044, vertical: height * 0.02),
                      child: Text(
                        "등록된 경로가 없습니다.",
                        style: TextStyle(
                          fontSize: width * 0.039,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              );
            }
          ),
        ],
      ),
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      child: Column(
        children: [
          SizedBox(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl.isNotEmpty
                        ? imageUrl
                        : 'https://cdn.pixabay.com/photo/2016/11/29/02/02/beach-1867285_1280.jpg', // default image
                    width: width * 0.333,
                    height: height * 0.145,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: width * 0.333,
                      height: height * 0.145,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 22.6),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal:  width * 0.022),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row( //여행명
                        children: [
                          const Icon(Icons.pin_drop, size: 22.6),
                          SizedBox(width: width * 0.011),
                          Wrap( //장소명
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox( //장소명
                                width: width * 0.416,
                                child: Text(
                                  placeName.replaceAll(RegExp(r'[<>]'), ''),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.0087),
                      Row( //주소
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Icon(Icons.home, size: width * 0.055), //없는게 더 이쁜듯
                          SizedBox(width: width * 0.011),
                          Column( //주소
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap( //도로명
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container( //도로명 설명
                                    padding: EdgeInsets.symmetric(horizontal:  width * 0.0083, vertical:  width * 0.0055),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: const Text("도로명", style: TextStyle(fontSize: 14.3)),
                                  ),
                                  SizedBox(width: width * 0.016),
                                  SizedBox( //도로명 데이터
                                    width: width * 0.361,
                                    child: Text(
                                      roadAddress.replaceAll(RegExp(r'[<>]'), ''),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(fontSize: 14.3),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.0073),
                              Wrap( //지번
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container( //지번 설명
                                    padding: EdgeInsets.symmetric(horizontal:  width * 0.0083, vertical:  width * 0.0055),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: const Text("지번", style: TextStyle(fontSize: 14.3)),
                                  ),
                                  SizedBox(width: width* 0.0416),
                                  SizedBox( //지번 데이터
                                    width: width * 0.361,
                                    child: Text(
                                      numberAddress.replaceAll(RegExp(r'[<>]'), ''),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(fontSize: 14.3),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.022),
          Events(mapX: mapX, mapY: mapY),
          SizedBox(height: height * 0.022)
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
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
                size: width * 0.055,
              ),
              SizedBox(width: width * 0.011),
              Text(
                _isExpanded ? "주변 행사 닫기" : "주변 행사 보기",
                style: const TextStyle(color: Colors.grey, fontSize: 16.5),
              ),
            ],
          ),
        ),

        SizedBox(height: height * 0.0174),

        // 🔳 카드 목록 (보일 때만)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: events.isEmpty
              ? Row( //주변행사가 없을때
                  children: [
                    SizedBox(width: width * 0.0166),
                    const Text(
                      "주변 행사가 없습니다.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: events.map((event) {
                      return Padding(
                        padding: EdgeInsets.only(right: width * 0.0333),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => nearEvents(eventData: event),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(vertical: height * 0.0333, horizontal: width * 0.0222),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: height * 0.0087),
                              Text(
                                event['title'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.5,
                                ),
                              ),
                              Text(
                                event['category'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}