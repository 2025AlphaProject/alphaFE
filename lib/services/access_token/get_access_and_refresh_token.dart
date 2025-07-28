import 'package:alpha_fe/services/access_token/save_access_and_refresh_token.dart';
import 'package:dio/dio.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

Future<void> getAccessAndRefreshToken(OAuthToken token) async {
  try {
    final dio = Dio();
    final formData = FormData.fromMap({'id_token': token.idToken});

    final response = await dio.post(
      'http://3.34.125.36:80/auth/login/',
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    await saveAccessToken(response.data['tokens']['access_token']);
    await saveRefreshToken(response.data['tokens']['refresh_token']);

  } catch (e) {
    throw Exception("getAccessAndRefreshToken error: $e");
  }
}