import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const DefaultAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // AppBar에 그림자 효과 추가
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      height: 120,
      child: AppBar(
        title: Text(title),
        backgroundColor: Color(0xFFFFFFFF),
      ),
    );
  }

  // AppBar 높이 설정 (kToolbarHeight = 기본 높이)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // SafeArea -> 노치 등 시스템 UI와 겹치지 않게 함
    return SafeArea(

      // appBar 대신 Container 반환
      child: Container(
        height: preferredSize.height,
        color: Colors.transparent, // AppBar 배경 없음
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),

          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: '가고싶은 여행지를 검색하세요!',
              hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),

              // 입력 가능할 경우(아무 동작도 하지 않았을 때) 검색창 스타일
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFD9D9D9))
              ),

              // 입력 중일 경우 검색창 스타일
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9))
              ),

              // 입력 중인 텍스트에 대한 패딩
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

              // 검색창 우측 부분에 표시될 아이콘
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF1E1E1E)),
                onPressed: () {
                  // 더미 검색 기능
                  debugPrint("검색 버튼 클릭됨 (추후 기능 연결 예정)");
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}