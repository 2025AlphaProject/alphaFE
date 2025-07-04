import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<Map<String, dynamic>> FetchMyInfo({
  required BuildContext context,
}) async {
  try{
    final dio = await getAuthorizedDio(context);
    final response = await dio.get('http://conever.duckdns.org:8000/user/me/');
    return response.data;
  } catch (e) {
    throw Exception("FetchMyInfo Error: $e");
  }
}