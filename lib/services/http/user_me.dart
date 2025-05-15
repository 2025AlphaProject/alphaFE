import 'package:flutter/cupertino.dart';

import '../dio/authorized_dio.dart';

class UserService {
  static Future<String> getCurrentUsername(BuildContext context) async {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get('http://conever.duckdns.org:8000/user/me/');
    return response.data['username'];
  }
}