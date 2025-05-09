import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

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

// 엑세스 토큰 저장
Future<void> saveAccessToken(String? token) async {
  if (!kIsWeb) {
    await secureStorage.write(key: 'access_token', value: token);
  }
}

// 엑세스 토큰 읽기
Future<String?> getAccessToken() async {
  if (!kIsWeb) {
    return await secureStorage.read(key: 'access_token');
  }
  return null;
}

// 엑세스 토큰 삭제
Future<void> deleteAccessToken() async {
  if (!kIsWeb) {
    await secureStorage.delete(key: 'access_token');
  }
}