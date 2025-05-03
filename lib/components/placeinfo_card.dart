import 'package:flutter/material.dart';


// 장소 이미지, 이름, 설명을 표시하는 카드형 컴포넌트
// mapX, mapY는 해당 장소의 WGS 좌표로, 주변 행사 검색 등에 사용 가능
class PlaceInfoBlock extends StatelessWidget {
  final String imageUrl; // 장소 이미지 URL
  final String title; // 장소 이름
  final String description; // 장소 설명
  final width;
  final height;

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
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // 장소 정보를 카드 형태로 렌더링
    return Container(
      width: width, // 카드 전체 영역의 너비
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // 이미지 모서리 둥글게 처리
            // 네트워크 이미지가 로딩되지 않을 경우 대체 UI를 표시
            child: Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              // 이미지 로딩 실패 시 회색 배경과 깨진 아이콘 표시
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey.shade300,
                  // 깨진 이미지 아이콘 표시
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade700,
                    size: width * 0.2,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: width * 0.05 ),

          // 장소명 표시
          Row(
            children: [
              Icon(Icons.location_on, size: width * 0.1, color: Color(0xFF000000)),
              SizedBox(width: width * 0.03),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.038),

          // 장소 설명 표시
          Text(
            description,
            style: TextStyle(
              fontSize: width * 0.052,
              color: Color(0xFF7A7A7A),
            ),
          ),
        ],
      ),
    );
  }
}