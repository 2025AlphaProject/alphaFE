import 'package:alpha_fe/mainscreen.dart';
import 'package:alpha_fe/pages/home_page/home_page.dart';
import 'package:alpha_fe/pages/plan_page/add_user/viewModel/add_user_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alpha_fe/components/appbars/default_appbar/default_appbar.dart';
import 'package:provider/provider.dart';

import '../../../services/http/add_user_to_tour/add_user.dart';

class ProfileListPage extends StatelessWidget {
  final int tour_id;
  const ProfileListPage({super.key, required this.tour_id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "친구추가"),
      body: ProfileListBody(tour_id: tour_id),
      backgroundColor: Colors.white,
    );
  }
}

class ProfileListBody extends StatefulWidget {
  final int tour_id;
  const ProfileListBody({super.key, required this.tour_id});

  @override
  State<ProfileListBody> createState() => _ProfileListBodyState();
}

class _ProfileListBodyState extends State<ProfileListBody> {
  final TextEditingController _searchController = TextEditingController();
  // _profiles 제거됨, ViewModel 사용

  late final int tour_id;

  @override
  void initState() {
    super.initState();
    tour_id = widget.tour_id;
    final viewModel = context.read<AddUserViewModel>();
    viewModel.loadUsers(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height* 0.02),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration( //원하는 유저 검색가능
                hintText: '검색...',
                hintStyle: const TextStyle(fontSize: 16.5),
                prefixIcon: const Icon(Icons.search, size: 24.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(fontSize: 16.5),
              onSubmitted: (value) {
                setState(() {}); // 엔터 누르면 화면 리빌드
              },
            ),
          ),

          Expanded(
            child: Consumer<AddUserViewModel>(
              builder: (context, viewModel, _) {
                final profiles = viewModel.filteredUsers;
                return ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    if (_searchController.text.isEmpty ||
                        profile.username.contains(_searchController.text)) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.02,
                            vertical: height * 0.005),
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: profile.profileImageUrl != null && profile.profileImageUrl != ""
                                      ? NetworkImage(profile.profileImageUrl!)
                                      : null,
                                child: profile.profileImageUrl == null || profile.profileImageUrl == ""
                                    ? const Icon(Icons.person, size: 24.6)
                                    : null,
                                ),
                                title: Text(
                                  profile.username,
                                  style: const TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: const Color(0xFFF9F9F9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        width: width,
                                        padding: EdgeInsets.all(width * 0.05),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '추가 확인',
                                              style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: height * 0.011),
                                            const Text(
                                              '이 유저를 추가하시겠습니까?',
                                              style: TextStyle(fontSize: 16.5),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: height * 0.023),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text(
                                                    '취소',
                                                    style: TextStyle(fontSize: 18.5, color: Colors.black),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.black,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final success = await addUserToTour(
                                                      context: context,
                                                      tourId: tour_id,
                                                      sub: profile.sub.toString(),
                                                    );
                                                    if (success) {
                                                      Navigator.pop(context);
                                                      Navigator.of(context).pushReplacement(
                                                        MaterialPageRoute(builder: (context) =>
                                                            Center(
                                                                child: Container(
                                                                  width: kIsWeb ? 430 : null,
                                                                  color: Colors.white,
                                                                  child: MainScreen(),
                                                                )
                                                            )
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: const Text(
                                                    '확인',
                                                    style: TextStyle(fontSize: 18.5, color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.add, size: 24.6),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
