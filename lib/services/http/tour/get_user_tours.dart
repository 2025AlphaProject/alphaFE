import 'package:flutter/cupertino.dart';
import '../../dio/authorized_dio.dart';

Future<List<dynamic>> GetUserTours({
  required BuildContext context,
  required String username,
}) async {
  final dio = await getAuthorizedDio(context);
  final response = await dio.get('http://conever.duckdns.org:8000/tour/');
  final allPlans = response.data as List;

  return allPlans.where((plan) {
    final users = plan['user'] ?? [];
    return users.any((u) => u['username'] == username);
  }).toList();
}
