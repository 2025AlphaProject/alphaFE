import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<void> saveRefreshToken(String? token) async {
  if (!kIsWeb) {
    await secureStorage.write(key: 'refresh_token', value: token);
  }
}

Future<String?> getRefreshToken() async {
  if (!kIsWeb) {
    return await secureStorage.read(key: 'refresh_token');
  }
  return null;
}

Future<void> deleteRefreshToken() async {
  if (!kIsWeb) {
    await secureStorage.delete(key: 'refresh_token');
  }
}

Future<void> saveAccessToken(String? token) async {
  if (!kIsWeb) {
    await secureStorage.write(key: 'access_token', value: token);
  }
}

Future<String?> getAccessToken() async {
  if (!kIsWeb) {
    return await secureStorage.read(key: 'access_token');
  }
  return null;
}

Future<void> deleteAccessToken() async {
  if (!kIsWeb) {
    await secureStorage.delete(key: 'access_token');
  }
}