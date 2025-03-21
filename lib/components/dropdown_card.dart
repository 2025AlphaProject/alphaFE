import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../pages/add_page/add_page_2.dart';

class DropItem extends StatelessWidget {
  final String title; // 드롭다운 제목 (예: 서초구, 중구 등 행정구역)
  final List<Map<String, String>> items; // 카드 목록 데이터 (imageUrl, title, description 포함)

  const DropItem({
    required this.title,
    required this.items,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5), // 회색 테두리
        borderRadius: BorderRadius.circular(12), // 모서리 둥글게 처리
        color: Color(0xFFF5F5F5), // 배경색
      ),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),

        // 드롭다운 확장 시 가로로 카드 나열
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                return InkWell(
                  // 카드 클릭 시 AddPage_2로 이동, 해당 지역 정보 전달
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AddPage_2(
                          title: title,
                          place: item['title']!,
                        ),
                      ),
                    );
                  },
                  child: CardItem(
                    imageUrl: item['imageUrl']!,
                    title: item['title']!,
                    description: item['description']!,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const CardItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 각 카드 아이템의 전체 구성 요소 묶음
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 235,
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 영역
          Container(
            width: 190,
            height: 150,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                  bottom: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 텍스트 영역 (장소 이름 + 설명)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(description, style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}