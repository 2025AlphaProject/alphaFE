import 'package:flutter/material.dart';
import '../../../../services/http/user_me/user_me.dart';
import '../models/user_profile.dart';

class AddUserViewModel extends ChangeNotifier {
  final UserService _service = UserService();

  List<UserProfile> allUsers = [];
  List<UserProfile> filteredUsers = [];
  bool isLoading = false;

  Future<void> loadUsers(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final myInfo = await _service.fetchMyInfo(context);
    final rawUsers = await _service.fetchAllUsers(context);
    print(rawUsers);

    allUsers = rawUsers
        .where((u) => u['sub'] != myInfo['sub'])
        .map((u) => UserProfile.fromJson(u))
        .toList();

    filteredUsers = allUsers;
    print(filteredUsers);
    isLoading = false;
    notifyListeners();
  }

  void filter(String keyword) {
    filteredUsers = allUsers
        .where((u) => u.username.contains(keyword))
        .toList();
    notifyListeners();
  }

  Future<bool> addUser(String sub, int tourId, BuildContext context) {
    return _service.addUserToTour(context, sub, tourId);
  }
}