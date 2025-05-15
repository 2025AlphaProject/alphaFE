// lib/model/place_info.dart

class PlaceInfo {
  final String title;
  final String description;
  final String imageUrl;
  final double mapX;
  final double mapY;

  PlaceInfo({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.mapX,
    required this.mapY,
  });

  // JSON 데이터를 PlaceInfo 객체로 변환하는 팩토리 함수
  factory PlaceInfo.fromJson(Map<String, dynamic> json, {required bool isWeb}) {
    final originalUrl = json['image1']?.toString() ?? '';
    final secureUrl = originalUrl.replaceFirst('http://', '');
    final imageUrl = (secureUrl.isNotEmpty)
        ? (isWeb ? 'https://images.weserv.nl/?url=$secureUrl' : 'http://$secureUrl')
        : '';

    return PlaceInfo(
      title: json['title'] ?? '제목 없음',
      description: json['address'] ?? '주소 정보 없음',
      imageUrl: imageUrl,
      mapX: double.tryParse(json['mapX']?.toString() ?? '0') ?? 0.0,
      mapY: double.tryParse(json['mapY']?.toString() ?? '0') ?? 0.0,
    );
  }
}