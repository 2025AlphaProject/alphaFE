import 'package:dio/dio.dart';
import '../../dio/authorized_dio.dart';

Future<Response> CheckMissionComplete(int tourId, int placeId, int missionId) async {
  final dio = await getAuthorizedDio();
  final data = {
    "travel_id": tourId,
    "place_id": placeId,
    "mission_id": missionId,
  };
  try {
    return await dio.post('http://3.34.125.36:80/mission/check_complete/', data: data);
  } catch (e) {
    throw Exception('CheckMissionComplete Error: $e');
  }
}