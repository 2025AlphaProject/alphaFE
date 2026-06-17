import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return '위치 서비스를 사용할 수 없습니다.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return '위치 권한이 거부되었습니다.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return '위치 권한이 영구적으로 거부되었습니다.';
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return '위도: ${position.latitude}, 경도: ${position.longitude}';
  }
}

//실사용 예시

// import 'package:flutter/material.dart';
// import 'location_service.dart'; // 경로는 실제 파일 경로에 맞게 조정
//
// class GPSPage extends StatefulWidget {
//   @override
//   _GPSPageState createState() => _GPSPageState();
// }
//
// class _GPSPageState extends State<GPSPage> {
//   String _location = '위치를 불러오는 중...';
//   final LocationService _locationService = LocationService();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLocation();
//   }
//
//   void _loadLocation() async {
//     final location = await _locationService.getCurrentLocation();
//     setState(() {
//       _location = location;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('현재 위치 확인')),
//       body: Center(child: Text(_location)),
//     );
//   }
// }