import 'package:flutter/material.dart';


// 장소 이미지, 이름, 설명을 표시하는 카드형 컴포넌트
// mapX, mapY는 해당 장소의 WGS 좌표로, 주변 행사 검색 등에 사용 가능
class PlaceInfoBlock extends StatelessWidget {
  final String imageUrl; // 장소 이미지 URL
  final String title; // 장소 이름
  final String description; // 장소 설명

  // 주변 행사정보를 불러오기 위해 X-경도, Y-위도 좌표 정보 저장(WGS)
  final double mapX;
  final double mapY;

  const PlaceInfoBlock({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.mapX,
    required this.mapY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // 장소 정보를 카드 형태로 렌더링
    return Container(
      width: 260, // 카드 전체 영역의 너비
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // 이미지 모서리 둥글게 처리
            child: Image.network(
              imageUrl,
              width: 260,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),

          // 장소명 표시
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Color(0xFF000000)),
              const SizedBox(width: 3),
              Expanded(
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

          // 장소 설명 표시
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