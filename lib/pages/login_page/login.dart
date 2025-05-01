import 'package:alpha_fe/mainscreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../home_page/home_page.dart';

class LoginPage extends StatelessWidget {
  final String? kakaoNativeAppKey;
  const LoginPage({super.key, this.kakaoNativeAppKey});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KakaoLoginPage(
        kakaoNativeAppKey: kakaoNativeAppKey,
      ),
    );
  }
}

class KakaoLoginPage extends StatefulWidget {
  final String? kakaoNativeAppKey;
  const KakaoLoginPage({super.key, this.kakaoNativeAppKey});
  @override
  _KakaoLoginPageState createState() => _KakaoLoginPageState();
}

class _KakaoLoginPageState extends State<KakaoLoginPage> {
  @override
  void initState() {
    super.initState();
    KakaoSdk.init(nativeAppKey: widget.kakaoNativeAppKey!);
  }
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

      // 사용자 정보 불러오기
      User user = await UserApi.instance.me();

      // 누락된 동의 항목 확인
      List<String> scopes = [];

      if (user.kakaoAccount?.profileNeedsAgreement == true) {
        scopes.add('profile_nickname');
      }

      // 추가 동의 필요한 항목 요청
      if (scopes.isNotEmpty) {
        token = await UserApi.instance.loginWithNewScopes(scopes);
        user = await UserApi.instance.me();
      }

      // 유저 등록
      final dio = Dio();
      try {
        final formData = FormData.fromMap({
          'id_token': token.idToken,
        });

        await dio.post(
          'http://conever.duckdns.org:8000/auth/login/',
          data: formData,
          options: Options(
            headers: {
              'Accept': 'application/json',  // Content-Type은 Dio가 자동 지정
            },
          ),
        );

        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(
              accessToken: token.accessToken,
            )));
      } catch (e) {
        print('❗ 사용자 등록 실패: $e');
      }
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
