import 'package:flutter/material.dart';
import 'pages/add_page/add_page_1.dart';
import 'pages/home_page/home_page.dart';
import 'pages/my_page/my_page.dart';
import 'pages/plan_page/plan_page.dart';
import 'components/bottom_navi_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 각 탭 별 Navigator 상태를 추적하기 위한 키 리스트
  late List<GlobalKey<NavigatorState>> _navigatorKeys;

  // 하단 탭에 연결될 페이지 목록
  final List<Widget> _pages = [
    const HomePage(),
    const PlanPage(),
    const AddPage(),
    const MyPage(),
  ];

  @override
  void initState() {
    super.initState();

    // 페이지 수만큼 Navigator 키 초기화
    _navigatorKeys = List.generate(
      _pages.length,
          (index) => GlobalKey<NavigatorState>(),
    );
  }

  // 안드로이드 '뒤로 가기' 동작 처리
  Future<bool> _onPop() async {
    final canPop = await _navigatorKeys[_currentIndex].currentState?.maybePop() ?? false;
    return !canPop;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 시스템 뒤로가기 버튼 제어: 앱이 곧바로 종료되지 않도록 처리
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onPop();
        }
        true;
      },

      child: Scaffold(
        extendBody: true,

        // IndexedStack으로 탭별 상태 유지 및 중첩 네비게이션 처리
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(_pages.length, (index) {
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => _pages[index],
              ),
            );
          }),
        ),

        // 하단 커스텀 네비게이션 바
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // 탭 전환 시 상태 갱신
            });
          },
        ),
      ),
    );
  }
}