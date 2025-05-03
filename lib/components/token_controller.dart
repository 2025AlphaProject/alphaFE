import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// 리프레시 토큰 저장
Future<void> saveRefreshToken(String? token) async {
  await secureStorage.write(key: 'refresh_token', value: token);
}

// 리프레시 토큰 읽기
Future<String?> getRefreshToken() async {
  return await secureStorage.read(key: 'refresh_token');
}

// 리프레시 토큰 삭제
Future<void> deleteRefreshToken() async {
  await secureStorage.delete(key: 'refresh_token');
}

// 엑세스 토큰 저장
Future<void> saveAccessToken(String? token) async {
  await secureStorage.write(key: 'access_token', value: token);
}

// 엑세스 토큰 읽기
Future<String?> getAccessToken() async {
  return await secureStorage.read(key: 'access_token');
}

// 엑세스 토큰 삭제
Future<void> deleteAccessToken() async {
  await secureStorage.delete(key: 'access_token');
}