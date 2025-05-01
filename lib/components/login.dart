import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:alpha_fe/mainscreen.dart';
import 'access_token_controller.dart';

class KakaoLoginService {
  static Future<void> login(BuildContext context, String kakaoNativeAppKey) async {
    KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('✅ 카카오톡 로그인 성공');
        } catch (error) {
          print('⚠️ 카카오톡 로그인 실패: $error');
          print('👉 웹 로그인으로 대체합니다');
          token = await UserApi.instance.loginWithKakaoAccount();
          print('✅ 웹 로그인 성공');
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('✅ 웹 로그인 성공');
      }

      print('✅ ID Token: ${token.idToken}');

      User user = await UserApi.instance.me();
      List<String> scopes = [];

      if (user.kakaoAccount?.profileNeedsAgreement == true) {
        scopes.add('profile_nickname');
      }

      if (scopes.isNotEmpty) {
        token = await UserApi.instance.loginWithNewScopes(scopes);
        user = await UserApi.instance.me();
      }

      final dio = Dio();
      final formData = FormData.fromMap({'id_token': token.idToken});
      await dio.post(
        'http://conever.duckdns.org:8000/auth/login/',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      await secureStorage.write(key: 'access_token', value: token.accessToken);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(accessToken: token.accessToken),
        ),
      );
    } catch (e) {
      print('❌ 로그인 전체 실패: $e');
    }
  }
}