import 'package:flutter/material.dart';
import 'plan_page_2_viewModel.dart';

class PlanInfoViewmodel extends ChangeNotifier{
  String _tourName = '';
  String _startDate = '';
  String _endDate = '';

  void updateFromPlan(PlanPage2ViewModel planVM) {
    _tourName = planVM.tourName;
    _startDate = planVM.startDate;
    _endDate = planVM.endDate;
    notifyListeners();
  }

  String get tourName => _tourName;
  String get startDate => _startDate;
  String get endDate => _endDate;

  // 날짜 기준으로만 계산, 진행중 - 종료 로직 추가
  String getRemainingStatus() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);

    if (today.isAfter(endOnly.add(Duration(days: 1)))) return '종료';
    if (!today.isBefore(startOnly)) return '진행중';

    final remaining = startOnly.difference(today).inDays;
    return 'D-$remaining';
  }

}