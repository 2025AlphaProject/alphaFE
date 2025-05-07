import 'package:alpha_fe/components/token_controller.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final logger = Logger();

Future<bool?> getAccessTokenFromRefreshToken() async {
  final refreshToken = await getRefreshToken();

  if (refreshToken == null) return false;

  try {
    final dio = Dio();
    final formData = FormData.fromMap({'refresh_token': refreshToken});
    final response = await dio.post(
      'http://conever.duckdns.org:8000/auth/refresh/',
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    final accessToken = response.data['access_token'];
    saveAccessToken(accessToken);
  } catch (e) {

    const secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');

    logger.e('🔁 accessToken 발급 실패: $e');
    return false;
  }
  logger.e('🔁 accessToken 발급 성공!');
  return true;
}
