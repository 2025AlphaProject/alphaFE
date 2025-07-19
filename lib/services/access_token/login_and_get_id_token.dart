import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:alpha_fe/mainscreen.dart';
import 'get_access_and_refresh_token.dart';

class KakaoLoginService {
  static Future<void> login(BuildContext context, {
    required String kakaoNativeAppKey,
    required String kakaoJavaScriptAppKey,
  }) async {
    if (kIsWeb) {
      KakaoSdk.init(javaScriptAppKey: kakaoJavaScriptAppKey);
    } else {
      KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
    }
    try {
      OAuthToken token;
      if (kIsWeb) {
        token = await UserApi.instance.loginWithKakaoAccount();
      } else if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      User user = await UserApi.instance.me();
      List<String> scopes = [];

      if (user.kakaoAccount?.profileNeedsAgreement == true) {
        scopes.add('profile_nickname');
      }

      if (scopes.isNotEmpty) {
        token = await UserApi.instance.loginWithNewScopes(scopes);
        user = await UserApi.instance.me();
      }

      await getAccessAndRefreshToken(token);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => kIsWeb
              ? Center(
                  child: Container(
                    width: kIsWeb ? 430 : null,
                    color: Colors.white,
                    child: MainScreen(),
                  ),
                )
              : MainScreen(),
        ),
      );
    } catch (e) {
      throw Exception("KakaoLoginService error: $e");
    }
  }
}
