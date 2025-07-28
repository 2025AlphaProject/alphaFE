import '../../dio/authorized_dio.dart';

Future<bool> CheckMissionService(int tdpId) async {
  try {
    final dio = await getAuthorizedDio();
    final response = await dio.get(
        'http://3.34.125.36:80/mission/is_complete/$tdpId/');
    if (response.statusCode == 200) {
      return response.data['mission_success'] ?? false;
    }
    return false;
  } catch (e) {
    throw Exception("CheckMissionService Error: $e");
  }
}