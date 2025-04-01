import 'package:flutter/material.dart';
import '../../components/app_bar.dart';           // 공통 AppBar 컴포넌트
import '../../components/trip_generator_card.dart';    // 여행지 선택용 드롭다운 카드

class AddPage extends StatelessWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      // 상단 앱바 설정
      appBar: const DefaultAppBar(title: "새 여행지 추가"),

      // 스크롤 가능한 콘텐츠 영역
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),

          // 안내 문구와 행정구역 단위별(시, 군, 구) 카드들을 세로로 배치
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 26),

              // 안내 문구 (가운데 정렬)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "✈️ 어디로 떠나볼까요?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "나머지는 저희에게 맡겨두세요!",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Color(0xFF757575)),
                  ),
                ]
              ),

              SizedBox(height: 50),

              // 서초구 GeneratorItem
              GeneratorItem(
                title: "서초구",
              ),

              // 용산구 GeneratorItem
              GeneratorItem(
                title: "용산구",
              ),

              // 마포구 GeneratorItem (현재 아이템 없음)
              GeneratorItem(
                title: "마포구",
              ),
            ],
          ),
        ),
      ),
    );
  }
}