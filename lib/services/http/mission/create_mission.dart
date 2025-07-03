import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<bool> CreateMissionService(BuildContext context, List<Map<String, dynamic>> todayPlaces) async {
  final dio = await getAuthorizedDio(context);
  final payload = {
    "places": todayPlaces.map((place) {
      return {
        "tdp_id": place["tdp_id"],
        "image_url": place["image_url"]?.toString() ?? "",
      };
    }).toList()
  };

  try {
    final response = await dio.post('http://conever.duckdns.org:8000/mission/random/', data: payload);
    return response.statusCode == 201;
  } catch (e) {
    throw Exception("CreateMissionService Error: $e");
  }
}