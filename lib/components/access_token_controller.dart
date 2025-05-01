import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// 저장
Future<void> saveAccessToken(String token) async {
  await secureStorage.write(key: 'access_token', value: token);
}

// 읽기
Future<String?> getAccessToken() async {
  return await secureStorage.read(key: 'access_token');
}

// 삭제
Future<void> deleteAccessToken() async {
  await secureStorage.delete(key: 'access_token');
}