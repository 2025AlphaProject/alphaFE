import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<Response?> CheckMissionComplete(BuildContext context, int tourId, int placeId, int missionId) async {
  final dio = await getAuthorizedDio(context);
  final data = {
    "travel_id": tourId,
    "place_id": placeId,
    "mission_id": missionId,
  };
  try {
    return await dio.post('http://conever.duckdns.org:8000/mission/check_complete/', data: data);
  } catch (e) {
    print('❌ 미션 진입 실패: $e');
    return null;
  }
}