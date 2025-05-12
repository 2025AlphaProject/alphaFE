import 'package:provider/provider.dart';
import 'package:alpha_fe/providers/auth_provider.dart';
import 'package:alpha_fe/components/navigation/global_context.dart';
import 'package:alpha_fe/components/access_token/refresh_token_storage_save.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<bool?> getAccessTokenFromRefreshToken() async {
  final refreshToken = await getRefreshToken();

  try {
    final dio = Dio();
    final formData = FormData.fromMap({'refresh_token': refreshToken});
    final response = await dio.post(
      'http://conever.duckdns.org:8000/auth/refresh/',
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    final accessToken = response.data['access_token'];
    Provider.of<AuthProvider>(navigatorKey.currentContext!, listen: false).setAccessToken(accessToken: accessToken);

  } catch (e) {
    logger.e('🔁 accessToken 발급 실패: $e');
    return false;
  }
  logger.e('🔁 accessToken 발급 성공!');
  return true;
}