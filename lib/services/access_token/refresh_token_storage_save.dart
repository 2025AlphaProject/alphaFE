import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// 리프레시 토큰 저장
Future<void> saveRefreshToken(String? token) async {
  if (!kIsWeb) {
    await secureStorage.write(key: 'refresh_token', value: token);
  }
}

// 리프레시 토큰 읽기
Future<String?> getRefreshToken() async {
  if (!kIsWeb) {
    return await secureStorage.read(key: 'refresh_token');
  }
  return null;
}

// 리프레시 토큰 삭제
Future<void> deleteRefreshToken() async {
  if (!kIsWeb) {
    await secureStorage.delete(key: 'refresh_token');
  }
}