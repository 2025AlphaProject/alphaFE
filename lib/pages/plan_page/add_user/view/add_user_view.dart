import 'package:alpha_fe/pages/plan_page/add_user/view/search_user_view.dart';
import 'package:alpha_fe/pages/plan_page/add_user/view/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AddUserView extends StatefulWidget {
  const AddUserView({super.key});

  @override
  State<AddUserView> createState() => _AddUserViewState();
}

class _AddUserViewState extends State<AddUserView> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) width = 430;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: height* 0.02),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
              child: const searchUser()
            ),
            Expanded(
              child: UserProfileView(),
            ),
          ],
        ),
      ),
    );
  }
}
