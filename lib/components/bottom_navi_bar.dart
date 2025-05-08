import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        // 배경 색, 위쪽 둥근 모서리, 그림자 효과 설정
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.0),
            topLeft: Radius.circular(30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, -2),
            )
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.073,
      
        // 둥근 모서리에 맞춰 BottomNavigationBar도 잘리도록 설정
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.0),
            topLeft: Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xFFFFFFFF),

            // 네비게이션 탭 시 ui 변화 없도록 수정
            selectedItemColor: Colors.grey.shade600,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.7
            ),
            unselectedLabelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.7
            ),
      
            // 하단 탭 항목 정의
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: '계획',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: '추가',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: '마이',
              ),
            ],
          ),
        ),
      ),
    );
  }
}