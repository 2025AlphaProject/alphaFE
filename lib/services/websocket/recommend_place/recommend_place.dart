import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../dio/authorized_dio.dart';

class RecommendPlaceService {
  static const _baseUrl = 'http://conever.duckdns.org:80';

  /// 사용자 ID를 최대 3회까지 시도해서 받아옴
  static Future<int?> fetchUserId(BuildContext context) async {
    final dio = await getAuthorizedDio(context);
    for (int i = 0; i < 3; i++) {
      try {
        final response = await dio.get('$_baseUrl/user/me/');
        return response.data['sub'];
      } catch (_) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }

  /// 랜덤 서울시 행정구역명 하나 리턴
  static String getRandomDistrict() {
    const districts = [
      "강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구",
      "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구",
      "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"
    ];
    return districts[Random().nextInt(districts.length)];
  }

  /// 이미지 URL을 플랫폼에 따라 안전하게 변환
  static String formatImageUrl(String? originalUrl) {
    if (originalUrl == null || originalUrl.isEmpty) return '';
    final secureUrl = originalUrl.replaceFirst('http://', '');
    return kIsWeb
        ? 'https://images.weserv.nl/?url=$secureUrl'
        : 'http://$secureUrl';
  }
}