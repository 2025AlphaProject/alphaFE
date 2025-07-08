import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<bool> CheckMissionService(BuildContext context, int tdpId) async {
  try {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get(
        'http://conever.duckdns.org:80/mission/is_complete/$tdpId/');
    if (response.statusCode == 200) {
      return response.data['mission_success'] ?? false;
    }
    return false;
  } catch (e) {
    throw Exception("CheckMissionService Error: $e");
  }
}