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
* 1. main.dart : runApp()을 통해 앱 실행, MainScreen으로 라우팅, 초기화가 필요한 패키지들 초기화 진행
* 2. mainscreen.dart : bottomNavigationBar의 동작 처리, 각 페이지(home, plan, add, my)로 라우팅
* pages : 각 페이지에 대한 dart 파일들
*   1. home page
*   2. plan page
*   3. add page
*   4. my page
* components : 네비바, 앱바, 각종 블록 단위 요소들을 각 페이지마다 호출해 사용할 수 있도록 구성
*   1. app_bar.dart : 그림자, 색상, 크기(높이) 정의 -> DefaultAppBar, SearchAppBar
*   2. bottom_navi_bar.dart : 색상, radius, Items(아이콘, 라벨) 정의
*   3. trip_generator_card.dart : 추가 탭의 첫 번째 페이지에 사용되는 드롭다운 박스 요소
*   4. plan_card.dart : 홈, 계획 탭에 사용되는 여행 정보를 나타내는 카드 요소
*   5. proceed_button.dart : 계획, 홈 탭에서 사용되는 버튼(검은색), 주로 다음 단계로 건너가기 위한 버튼으로 사용됨
*   6. placeinfo_card.dart : 추가 탭의 두 번째 페이지에 사용되는 여헹 코스의 장소 나열 시에 사용되는 카드 요소
*   7. placeinput_card.dart : 장소 정보를 입력하는 카드 컴포넌트, 사용자가 직접 입력하거나 검색 결과를 가져와 장소 정보를 설정할 수 있음
*   8. camera.dart
*   9. gps.dart
* */

import 'package:flutter/material.dart';
import 'mainscreen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

// 로거 사용을 위한 전역변수 선언
final logger = Logger();

// 네이버맵 sdk 초기화 함수
Future<void> initNaverMapSdk() async {
  await FlutterNaverMap().init(
      clientId: dotenv.env['NAVER_DYNAMIC_MAP'],

      // 인증 실패 시 실행될 콜백
      onAuthFailed: (ex) => switch (ex) {
        NQuotaExceededException(:final message) => logger.d('사용량 초과 (message: $message)'),
        NUnauthorizedClientException() ||
        NClientUnspecifiedException() ||
        NAnotherAuthFailedException() =>
          logger.d('인증 실패: $ex'),
      }
  );
}

// 유저 정보 불러오기 함수
Future<String?> fetchCurrentUsername() async {
  final dio = Dio();
  final baseUrl = 'http://conever.duckdns.org:8000';
  String? userName;

  try {
    final response = await dio.get(
      '$baseUrl/user/me/',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${dotenv.env['KAKAO_ACCESS_TOKEN']}',
          'Accept': 'application/json'
        },
      ),
    );
    userName = response.data['username'];
  } catch (e) {
    print('❗️ 사용자 정보 불러오기 실패: $e');
  }

  return userName;
}

Future<void> main() async {
  // 비동기 초기화 <- await 관련 코드 오류 방지하기 위해 사용
  WidgetsFlutterBinding.ensureInitialized();

  // dotenv 사용을 위한 초기화
  await dotenv.load();

  // 네이버맵 초기화 - 현재 안드로이드 환경에서만 사용 가능
  //await initNaverMapSdk();

  // 유저 이름 받아오기
  final username = await fetchCurrentUsername();

  // 앱 실행
  runApp(MyApp(username: username));
}

class MyApp extends StatelessWidget {

  final String? username;
  final String welcome_message = '오늘도 좋은 하루에요👋';

  const MyApp({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(
        username: username ?? '알 수 없는 유저',
        welcome_message: welcome_message,
      ),
    );
  }
}
