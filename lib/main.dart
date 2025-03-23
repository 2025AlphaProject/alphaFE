/*
* << 파일 변경사항에 따라 지속적으로 수정될 예정 >>
* - 2025-03-21: 최초 추가
* - 2025-03-23: proceed_button.dart 추가, app_bar.dart에 SearchBar 클래스 추가, plan_card.dart에 사이즈값 인자 추가
* < 네이밍 관련 >
* - 모든 코드 작성은 피그마 페이지를 기준으로 함
* - 같은 탭(홈,계획,추가,마이) 내의 페이지일 경우 <탭 이름>_<라우팅 순서>로 네이밍 함
*   - 라우팅 순서는 피그마 페이지에서 각 탭별로 왼쪽 -> 오른쪽 순서
*
* < 전반적인 코드 실행 흐름 >
* 1. main.dart : runApp()을 통해 앱 실행, MainScreen으로 라우팅
* 2. mainscreen.dart : bottomNavigationBar의 동작 처리, 각 페이지(home, plan, add, my)로 라우팅
* pages : 각 페이지에 대한 dart 파일
*   1. home page
*     - home_page.dart
*   2. plan page
*     - plan_page.dart
*   3. add page
*     - add_page_1.dart
*     - add_page_2.dart
*     - add_page_3.dart
*   4. my page
*     - my_page.dart
* components : 네비바, 앱바, 각종 블록 단위 요소들을 각 페이지마다 호출해 사용할 수 있도록 구성
*   1. app_bar.dart : 그림자, 색상, 크기(높이) 정의
*   2. bottom_navi_bar.dart : 색상, radius, Items(아이콘, 라벨) 정의
*   3. dropdown_card.dart : 추가 탭의 첫 번째 페이지에 사용되는 드롭다운 박스 요소
*   4. plan_card.dart : 홈, 계획 탭에 사용되는 여행 정보를 나타내는 카드 요소
*   5. proceed_button.dart : 계획, 홈 탭에서 사용되는 버튼(검은색), 주로 다음 단계로 건너가기 위한 버튼으로 사용됨
* */

import 'package:flutter/material.dart';
import 'mainscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String username = '홍길동';
  final String welcome_message = '오늘도 좋은 하루에요👋';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(
        username: username,
        welcome_message: welcome_message),
    );
  }
}
