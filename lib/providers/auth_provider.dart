import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;

  String? get accessToken {
    print(_accessToken);
    return _accessToken;
  }

  void setAccessToken({required String accessToken}) {
    _accessToken = accessToken;
    notifyListeners();
  }

  void clearAccessToken() {
    _accessToken = null;
    notifyListeners();
  }
}