import 'package:flutter/material.dart';
import '../../../../services/http/user/fetch_all_users.dart';
import '../../../../services/http/user/fetch_my_info.dart';
import '../models/user_profile.dart';

class AddUserViewModel extends ChangeNotifier {
  List<UserProfile> allUsers = [];
  List<UserProfile> filteredUsers = [];
  bool isLoading = false;

  Future<void> loadUsers(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final myInfo = await FetchMyInfo(context: context);
    final rawUsers = await FetchAllUsers(context: context);
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
}