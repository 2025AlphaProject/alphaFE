import 'package:alpha_fe/services/access_token/save_access_and_refresh_token.dart';
import 'package:alpha_fe/services/dio/unauthorized_dio.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<void> getAccessTokenFromRefreshToken() async {
  final refreshToken = await getRefreshToken();
  print("refreshToken: $refreshToken");
  try {
    final dio = await getUnauthorizedDio();
    final response = await dio.post(
      'http://3.34.125.36:80/auth/refresh/',
      data: {
        'refresh_token': refreshToken,
      },
    );
    saveAccessToken(response.data['access_token']);
    saveRefreshToken(response.data['refresh_token']);
  } catch (e) {
    throw Exception("getAccessTokenFromRefresh Token Error: $e");
  }
}