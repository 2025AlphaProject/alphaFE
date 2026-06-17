import 'package:alpha_fe/services/access_token/get_access_token_from_refresh_token.dart';

Future<bool> testAccessToken() async {
  try {
    await getAccessTokenFromRefreshToken();
    return true;
  } catch (e) {
    logger.e("testAccessToken Error: $e");
    return false;
  }
}