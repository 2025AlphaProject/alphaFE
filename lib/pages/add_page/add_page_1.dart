import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';           // 공통 AppBar 컴포넌트
import '../../components/trip_generator_card.dart';    // 여행지 선택용 드롭다운 카드

// 서울시 행정구역 목록
const List<String> districts = [
  "강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구",
  "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구",
  "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"
];

class AddPage_1 extends StatelessWidget {
  final String? accessToken;
  final int tourId;
  const AddPage_1({
    required this.tourId,
    Key? key, required this.accessToken
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      // 상단 앱바 설정
      appBar: const DefaultAppBar(title: "추천경로 생성하기"),

      // 스크롤 가능한 콘텐츠 영역
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.0138, horizontal: width * 0.065),

          // 안내 문구와 행정구역 단위별(시, 군, 구) 카드들을 세로로 배치
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: height * 0.0461),

              // 안내 문구 (가운데 정렬)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "✈️ 어디로 떠나볼까요?",
                    style: TextStyle(fontSize: 24.6, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "나머지는 저희에게 맡겨두세요!",
                    style: TextStyle(fontSize: 14.3, fontWeight: FontWeight.normal, color: Color(0xFF757575)),
                  ),
                ]
              ),

              SizedBox(height: height * 0.0692),

              // 행정구역 목록에 있는 요소들에 대해 GeneratorItem 생성
              ...districts.map((name) => GeneratorItem(title: name, tourId: tourId, accessToken: accessToken,)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}