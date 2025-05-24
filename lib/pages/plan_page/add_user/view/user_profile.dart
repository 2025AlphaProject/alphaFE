import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../viewModel/search_user_viewmodel.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) width = 430;
    double height = MediaQuery.of(context).size.height;

    return Consumer<searchUserViewModel>(
      builder: (context, viewModel, _) {
        final profiles = viewModel.filteredProfiles;

        return ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.02,
                vertical: height * 0.005,
              ),
              child: buildProfile(profile),
            );
          },
        );
      },
    );
  }
}

//유저들 프로필 나타내는 위젯
Widget buildProfile(Map<String, dynamic> profile) {
  final imageUrl = profile['profile_image_url'] as String?;
  final username = profile['username'] as String;

  return Row(
    children: [
      Expanded(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? NetworkImage(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? const Icon(Icons.person, size: 24.6)
                : null,
          ),
          title: Text(
            username,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      IconButton(onPressed: (){}, icon: Icon(Icons.add, size: 24.6),) //TODO: 여기 유저추가 연결
    ],
  );
}

