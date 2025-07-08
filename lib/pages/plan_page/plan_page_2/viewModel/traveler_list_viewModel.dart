import 'package:flutter/material.dart';
import 'plan_page_2_viewModel.dart';
import 'package:alpha_fe/pages/plan_page/add_user/add_user.dart';


class travelersViewModel extends ChangeNotifier{
  List<Map<String, String>> _travelers = [];
  Map<String, dynamic> _tourinfo = {};

  List<Map<String, String>> get travelers => _travelers;

  void updatePlan(PlanPage2ViewModel planVM) {
    _tourinfo = planVM.tourinfo;

    if (_tourinfo['user'] != null && _tourinfo['user'] is List) {
      _travelers = (_tourinfo['user'] as List).map<Map<String, String>>((user) {
        return {
          'name': user['username'] ?? '이름없음',
          'imageUrl': user['profile_image_url'] ?? 'https://via.placeholder.com/150',
        };
      }).toList();
    } else {
      _travelers = [];
    }

    notifyListeners();
  }

  void onInviteTapped(BuildContext context, int tourId, VoidCallback onRefresh) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileListPage(
          tour_id: tourId,
        ),
      ),
    );
    onRefresh(); // 돌아온 후 상태 갱신
  }

}