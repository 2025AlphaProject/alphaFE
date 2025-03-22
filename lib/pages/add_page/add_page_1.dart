import 'package:flutter/material.dart';
import '../../components/app_bar.dart';           // 공통 AppBar 컴포넌트
import '../../components/dropdown_card.dart';    // 여행지 선택용 드롭다운 카드

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

          // 안내 문구와 지역별 드롭다운 카드들을 세로로 배치
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 26),

              // 안내 문구 (가운데 정렬)
              Center(
                child: Text(
                  "✈️ 떠나고 싶은 장소가 있나요?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 26),

              // 서초구 DropItem
              DropItem(
                title: "서초구",
                items: [
                  {
                    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Bukak.jpg/440px-Bukak.jpg",
                    "title": "국민대학교",
                    "description": "죽기 전에 꼭 가봐야 할 대학순위 Top1dfdfdfddfdfdfdfdfdfdf"
                  },
                  {
                    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Bukak.jpg/440px-Bukak.jpg",
                    "title": "서울대학교",
                    "description": "명문대의 상징"
                  },
                ],
              ),

              // 용산구 DropItem
              DropItem(
                title: "용산구",
                items: [
                  {
                    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Bukak.jpg/440px-Bukak.jpg",
                    "title": "이태원",
                    "description": "외국 문화를 느낄 수 있는 곳"
                  },
                  {
                    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Bukak.jpg/440px-Bukak.jpg",
                    "title": "남산타워",
                    "description": "서울의 랜드마크"
                  },
                ],
              ),

              // 마포구 DropItem (현재 아이템 없음)
              DropItem(
                title: "마포구",
                items: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}