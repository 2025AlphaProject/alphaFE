import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KakaoLoginPage(),
    );
  }
}

class KakaoLoginPage extends StatelessWidget {
  Future<void> _loginWithKakao() async {
    try {
      OAuthToken token;

      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('✅ 카카오톡 로그인 성공');
        } catch (error) {
          print('⚠️ 카카오톡 로그인 실패: $error');
          print('👉 웹 로그인으로 대체합니다');

          // 카카오톡 로그인 실패 시 웹 로그인으로 fallback
          token = await UserApi.instance.loginWithKakaoAccount();
          print('✅ 웹 로그인 성공');
        }
      } else {
        // 카카오톡이 아예 설치 안 되어 있으면 바로 웹 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
        print('✅ 웹 로그인 성공');
      }

      print('✅ ID Token: ${token.idToken}');
      print('✅ Access Token: ${token.accessToken}');
      print('🔄 Refresh Token: ${token.refreshToken}');

      // 사용자 정보 불러오기
      User user = await UserApi.instance.me();

      // 누락된 동의 항목 확인
      List<String> scopes = [];

      if (user.kakaoAccount?.emailNeedsAgreement == true) {
        scopes.add('account_email');
      }

      if (user.kakaoAccount?.profileNeedsAgreement == true) {
        scopes.add('profile_nickname');
      }

      if (user.kakaoAccount?.ageRangeNeedsAgreement == true) {
        scopes.add('age_range');
      }

      // 추가 동의 필요한 항목 요청
      if (scopes.isNotEmpty) {
        token = await UserApi.instance.loginWithNewScopes(scopes);
        user = await UserApi.instance.me();
      }

      // 사용자 정보 출력
      print('✅ 로그인 성공!');
      print('이메일: ${user.kakaoAccount?.email}');
      print('닉네임: ${user.kakaoAccount?.profile?.nickname}');
      print('연령대: ${user.kakaoAccount?.ageRange}');
    } catch (e) {
      print('❌ 로그인 전체 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('카카오 로그인')),
      body: Center(
        child: ElevatedButton(
          onPressed: _loginWithKakao,
          child: Text('카카오로 로그인하기'),
        ),
      ),
    );
  }
}
