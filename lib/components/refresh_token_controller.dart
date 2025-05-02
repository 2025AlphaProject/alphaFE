import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// 저장
Future<void> saveRefreshToken(String? token) async {
  await secureStorage.write(key: 'refresh_token', value: token);
}

// 읽기
Future<String?> getRefreshToken() async {
  return await secureStorage.read(key: 'refresh_token');
}

// 삭제
Future<void> deleteRefreshToken() async {
  await secureStorage.delete(key: 'refresh_token');
}