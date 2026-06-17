import 'package:dio/dio.dart';
import '../../dio/authorized_dio.dart';

Future<Response> SaveMissionComplete(int tdpId, bool isSuccess) async {
  final dio = await getAuthorizedDio();
  final data = {
    "tdp_id": tdpId,
    "is_success": isSuccess,
  };
  try {
    return await dio.post('http://3.34.125.36:80/mission/save_mission_complete/', data: data);
  } catch (e) {
    throw Exception("SaveMissionComplete Error: $e");
  }
}
