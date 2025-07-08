import 'package:alpha_fe/services/access_token/refresh_token_storage_save.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:alpha_fe/providers/auth_provider.dart';

Future<void> getAccessAndRefreshToken(BuildContext context, OAuthToken token) async {
  try {
    print("📌 서버에 로그인 요청 전송 중...");
    final dio = Dio();
    final formData = FormData.fromMap({'id_token': token.idToken});

    final response = await dio.post(
      'http://conever.duckdns.org:80/auth/login/',
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    print("✅ 서버 응답 수신 완료: ${response.statusCode} ${response.data}");

    await saveRefreshToken(response.data['tokens']['refresh_token']);
    context.read<AuthProvider>().setAccessToken(accessToken: response.data['tokens']['access_token']);

    print("🚀 메인 화면으로 이동");
  } catch (e) {
    print("❌ 로그인 실패: $e");
    rethrow;
  }
}