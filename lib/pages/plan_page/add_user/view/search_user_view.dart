import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/search_user_viewmodel.dart';

class searchUser extends StatefulWidget {
  const searchUser({super.key});

  @override
  State<searchUser> createState() => _searchUserState();
}

class _searchUserState extends State<searchUser> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (text) {
        Provider.of<searchUserViewModel>(context, listen: false).setSearchText(text);
      },
      decoration: InputDecoration( //원하는 유저 검색가능
        hintText: '검색어를 입력하세요',
        hintStyle: const TextStyle(fontSize: 16.5),
        prefixIcon: const Icon(Icons.search, size: 24.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(fontSize: 16.5),
    );
  }
}
