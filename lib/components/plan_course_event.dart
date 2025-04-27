import 'package:flutter/material.dart';

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
                );
              }).toList(),
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
