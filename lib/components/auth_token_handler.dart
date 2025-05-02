import 'package:alpha_fe/components/refresh_token_controller.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<String?> getAccessTokenFromRefreshToken() async {
  final refreshToken = await getRefreshToken();

  if (refreshToken == null) return null;

  try {
    final dio = Dio();
    final formData = FormData.fromMap({'refresh_token': refreshToken});
    final response = await dio.post(
      'http://conever.duckdns.org:8000/auth/refresh/',
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return response.data['access_token'];
  } catch (e) {
    logger.e('🔁 accessToken 발급 실패: $e');
    return null;
  }
}