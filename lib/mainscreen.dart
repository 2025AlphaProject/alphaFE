import 'package:flutter/material.dart';
import 'pages/add_page/add_page_0.dart';
import 'pages/home_page/home_page.dart';
import 'pages/my_page/my_page.dart';
import 'pages/plan_page/plan_page.dart';
import 'components/bottom_navi_bar.dart';

class MainScreen extends StatefulWidget {
  final String? accessToken;
  const MainScreen({super.key, this.accessToken});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // 각 탭 별 Navigator 상태를 추적하기 위한 키 리스트
  late List<GlobalKey<NavigatorState>> _navigatorKeys;

  // 하단 탭에 연결될 페이지 목록
  List<Widget> get _pages => [
    HomePage(
      accessToken: widget.accessToken,
    ),
    PlanPage(
      accessToken: widget.accessToken,
    ),
    AddPage_0(
      accessToken: widget.accessToken,
    ),
    MyPage(
      accessToken: widget.accessToken,
    ),
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
    final canPop = await _navigatorKeys[_currentIndex].currentState
        ?.maybePop() ?? false;
    return !canPop;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onPop();
        }
        true;
      },
      child: Scaffold(

        //  IndexedStack 제거 → 상태 유지 안함
        //  선택된 탭 페이지만 직접 렌더링
        body: Navigator(
          key: _navigatorKeys[_currentIndex],
          onGenerateRoute: (settings) =>
              MaterialPageRoute(
                builder: (context) => _pages[_currentIndex],
              ),
        ),


        // Container로 감싸 네비바에서 색상이 적용되지 않는 부분까지 색을 덧씌움, extendBody 비활성화
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height*0.085,
          color: Color(0xFFFFFFFF),
          child: CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}