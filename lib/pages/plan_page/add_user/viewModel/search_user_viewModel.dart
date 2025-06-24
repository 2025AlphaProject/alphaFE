import 'package:flutter/material.dart';

class searchUserViewModel extends ChangeNotifier{
  List<Map<String, dynamic>> _profiles = [];
  String _searchText = '';
  bool _isLoading = false;

  List<Map<String, dynamic>> get profiles => _profiles;
  String get searchText => _searchText;
  bool get isLoading => _isLoading;

  /// 필터링된 목록 반환
  List<Map<String, dynamic>> get filteredProfiles {
    if (_searchText.isEmpty) return _profiles;
    return _profiles
        .where((p) => p['username'].toString().contains(_searchText))
        .toList();
  }
  void setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }
}