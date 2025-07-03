import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<List<Map<String, dynamic>>> FetchAllUsers ({
  required BuildContext context,
}) async {
  final dio = await getAuthorizedDio(context);
  final response = await dio.get('http://conever.duckdns.org:8000/user/');
  return List<Map<String, dynamic>>.from(response.data);
}