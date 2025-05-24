import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/models/place_info.dart';
import 'dart:async';

class AddPage2ViewModel extends ChangeNotifier {
  bool isEditMode = false;
  ValueNotifier<String?> selectedDate = ValueNotifier(null);

  final Map<String, bool> isAddingPlaceMap = {};
  final Map<String, List<PlaceInfo>> placeInfos = {};

  bool _hasInitialized = false;

  void onViewEnter() {
    if (!_hasInitialized) {
      resetState();
      _hasInitialized = true;
    }
  }

  void toggleEditMode() {
    isEditMode = !isEditMode;
    notifyListeners();
  }

  void updateSelectedDate(String? date) {
    selectedDate.value = date;
    notifyListeners();
  }

  void toggleAddingPlace(String date, bool isAdding) {
    isAddingPlaceMap[date] = isAdding;
    notifyListeners();
  }

  void addNewPlace(String date, PlaceInfo newPlace) {
    if (placeInfos.containsKey(date)) {
      placeInfos[date]!.add(newPlace);
    } else {
      placeInfos[date] = [newPlace];
    }

    isAddingPlaceMap[date] = false;
    notifyListeners();
  }

  void removePlace(String date, PlaceInfo place) {
    if (placeInfos.containsKey(date)) {
      placeInfos[date]!.remove(place);
      notifyListeners();
    }
  }

  bool isDuplicatePlace(String date, String title, String address) {
    if (!placeInfos.containsKey(date)) return false;

    final existingList = placeInfos[date]!;

    // 장소명 중복 검사
    final titleMatch = existingList.any((place) => place.title == title);
    if (titleMatch) return true;

    // 주소 유사도 검사: 괄호 제거 후 공백 제거 비교
    String normalize(String s) {
      return s.replaceAll(RegExp(r'\s*\([^)]*\)'), '').replaceAll(RegExp(r'\s+'), '');
    }

    final normalizedNewAddress = normalize(address);

    for (final place in existingList) {
      if (normalize(place.description) == normalizedNewAddress) {
        return true;
      }
    }

    return false;
  }

  bool get visibleButton => _visibleButton;

  void handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;
      if (direction == ScrollDirection.idle) {
        _idleTimer ??= Timer(const Duration(milliseconds: 750), () {
          showFloatButton();
        });
      } else {
        _idleTimer?.cancel();
        _idleTimer = null;
        if (_visibleButton) hideFloatButton();
      }
    }
  }

  void showFloatButton() {
    if (!_visibleButton) {
      _visibleButton = true;
      notifyListeners();
    }
  }

  void hideFloatButton() {
    if (_visibleButton) {
      _visibleButton = false;
      notifyListeners();
    }
  }

  bool _visibleButton = true;
  Timer? _idleTimer;

  void resetState() {
    isEditMode = false;
    selectedDate.value = null;
    isAddingPlaceMap.clear();
    placeInfos.clear();
    _visibleButton = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    _hasInitialized = false;
    notifyListeners();
  }


}
