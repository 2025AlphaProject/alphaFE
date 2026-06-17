import 'package:alpha_fe/services/access_token/save_access_and_refresh_token.dart';
import 'package:dio/dio.dart';

Future<Dio> getAuthorizedDio() async {
  final dio = Dio();
  final accessToken = await getAccessToken();
  dio.options.headers = {
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  return dio;
}
