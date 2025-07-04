import 'package:flutter/cupertino.dart';
import '../../dio/authorized_dio.dart';

Future<List<dynamic>> fetchAllTours(BuildContext context) async {
  try {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get('http://conever.duckdns.org:8000/tour/');
    return response.data as List;
  } catch (e) {
    throw Exception("fetchAllTours Error: $e");
  }
}
