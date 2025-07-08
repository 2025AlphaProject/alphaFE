import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<Response> SaveMissionComplete(BuildContext context, int tdpId, bool isSuccess) async {
  final dio = await getAuthorizedDio(context);
  final data = {
    "tdp_id": tdpId,
    "is_success": isSuccess,
  };
  try {
    return await dio.post('http://conever.duckdns.org:80/mission/save_mission_complete/', data: data);
  } catch (e) {
    throw Exception("SaveMissionComplete Error: $e");
  }
}
