import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../pages/add_page/add_page_2.dart';

class DropItem extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

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
        border: Border.all(color: Colors.grey.shade300, width: 1.5), // 테두리 추가
        borderRadius: BorderRadius.circular(12), // 모서리 둥글게
        color: Color(0xFFF5F5F5), // 배경색 설정
      ),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
            child: Row(
              children: items.map((item) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => AddPage_2(title: title, place: item['title']!,))
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
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 235,
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Container(
            width: 190, // 카드의 고정 너비 설정
            height: 150,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(12)), // 이미지 모서리 둥글게
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover, // 이미지 크기 조정
                ),
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
