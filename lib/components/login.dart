import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:alpha_fe/mainscreen.dart';
import 'token_controller.dart';

class KakaoLoginService {
  static Future<void> login(BuildContext context, {
    required String kakaoNativeAppKey,
    required String kakaoJavaScriptAppKey,
  }) async {
    if (kIsWeb) {
      KakaoSdk.init(javaScriptAppKey: kakaoJavaScriptAppKey);
      print(kakaoJavaScriptAppKey);
    } else {
      KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
    }
    try {
      OAuthToken token;

      if (kIsWeb) {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('✅ 웹 로그인 성공');
      } else if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('✅ 카카오톡 로그인 성공');
        } catch (error) {
          print('⚠️ 카카오톡 로그인 실패: $error');
          print('👉 카카오 계정 로그인으로 대체합니다');
          token = await UserApi.instance.loginWithKakaoAccount();
          print('✅ 로그인 성공');
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('✅ 로그인 성공');
      }

      print('✅ ID Token: ${token.idToken}');

      print("📌 사용자 정보 요청 중...");
      User user = await UserApi.instance.me();
      print("✅ 사용자 정보 획득: ${user.id}");

      List<String> scopes = [];

      if (user.kakaoAccount?.profileNeedsAgreement == true) {
        print("ℹ️ profile_nickname 동의 필요 → scopes 추가");
        scopes.add('profile_nickname');
      }

      if (scopes.isNotEmpty) {
        print("📌 추가 scopes 요청 중: $scopes");
        token = await UserApi.instance.loginWithNewScopes(scopes);
        user = await UserApi.instance.me();
        print("✅ scopes 동의 후 사용자 정보 재획득 완료");
      }

      print("📌 서버에 로그인 요청 전송 중...");
      final dio = Dio();
      final formData = FormData.fromMap({'id_token': token.idToken});
      var response = await dio.post(
        'http://conever.duckdns.org:8000/auth/login/',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );
      print("✅ 서버 응답 수신 완료: ${response.statusCode} ${response.data}");

      saveRefreshToken(token.refreshToken);
      saveAccessToken(token.accessToken);

      print("🚀 메인 화면으로 이동");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => kIsWeb
              ? Center(
                  child: Container(
                    width: kIsWeb ? 430 : null,
                    color: Colors.white,
                    child: MainScreen(accessToken: token.accessToken,),
                  ),
                )
              : MainScreen(accessToken: token.accessToken,),
        ),
      );
    } catch (e) {
      print('❌ 로그인 전체 실패: $e');
    }
  }
}
