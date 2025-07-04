import 'package:flutter/material.dart';
import '../../seoul_districts.dart';

class SearchAppBarViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _filteredDistricts = [];

  String get searchQuery => _searchQuery;
  List<String> get filteredDistricts => _filteredDistricts;

  // 외부에서 오버레이 관리 등을 위해 리스너를 직접 제어할 수 있도록 public으로 제공
  void onSearchChanged() {
    _searchQuery = searchController.text;
    _filteredDistricts = seoulDistricts
        .where((gu) => gu.contains(_searchQuery))
        .toList();
    notifyListeners();
  }

  void init() {
    // 리스너 등록 시 중복 방지
    searchController.removeListener(onSearchChanged);
    searchController.addListener(onSearchChanged);
  }

  void clear() {
    _searchQuery = '';
    _filteredDistricts = [];
    searchController.clear();
    notifyListeners();
  }
}