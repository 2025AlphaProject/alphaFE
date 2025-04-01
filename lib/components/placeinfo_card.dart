import 'package:flutter/material.dart';

class PlaceInfoBlock extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const PlaceInfoBlock({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260, // 전체 너비 제한
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 영역
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              width: 260, // 이미지도 동일한 너비 적용
              height: 180,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          // 📍 아이콘 + 장소명
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Color(0xFF000000)),
              const SizedBox(width: 3),
              Expanded( // 텍스트가 길어도 잘리지 않도록 처리
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 설명 텍스트
          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF7A7A7A),
            ),
          ),
        ],
      ),
    );
  }
}