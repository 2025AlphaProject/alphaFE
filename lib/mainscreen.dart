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

  // 각 탭에 대한 Navigator 키 리스트 정의
  late List<GlobalKey<NavigatorState>> _navigatorKeys;

  // 각 페이지를 리스트로 정의
  final List<Widget> _pages = [
    const HomePage(),
    const PlanPage(),
    const AddPage(),
    const MyPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 각 탭에 대한 Navigator 키 초기화
    _navigatorKeys =
        List.generate(_pages.length, (index) => GlobalKey<NavigatorState>());
  }

  Future<bool> _onPop() async {
    // 현재 활성화된 탭의 Navigator에서 뒤로 가기 동작 처리
    final canPop = await _navigatorKeys[_currentIndex].currentState?.maybePop() ?? false;
    return !canPop;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop){
          await _onPop();
        }
        true;
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex, // 현재 선택된 페이지만 표시
          children: List.generate(_pages.length, (index) {
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (context) => _pages[index]
              ),
            );
          })
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // 페이지 전환
            });
          },
        ),
      ),
    );
  }
}
