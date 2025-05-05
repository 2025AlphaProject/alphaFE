import 'dart:math';

class LocationUtils {
  // 두 지점 위도/경도를 입력받아 거리(km)를 반환하는 Haversine 함수
  static double haversine(double place_mapY, double place_mapX, double user_mapY, double user_mapX) {
    const double R = 6378; // 지구 반지름 (단위: km)

    // 라디안으로 변환
    double dLat = _degToRad(user_mapY - place_mapY);
    double dLon = _degToRad(user_mapX - place_mapX);
    double rLat1 = _degToRad(place_mapY);
    double rLat2 = _degToRad(user_mapY);

    // Haversine 공식 적용
    double a = pow(sin(dLat / 2), 2) +
        cos(rLat1) * cos(rLat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  // 도(degree)를 라디안으로 변환
  static double _degToRad(double degree) {
    return degree * pi / 180;
  }
}