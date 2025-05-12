import 'package:alpha_fe/components/access_token/refresh_token_storage_save.dart';
import 'package:alpha_fe/mainscreen.dart';
import 'package:alpha_fe/pages/home_page/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/components/app_bar.dart';

class ProfileListPage extends StatelessWidget {
  final String? accessToken;
  final int tour_id;
  const ProfileListPage({super.key, required this.tour_id, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "친구추가"),
      body: ProfileListBody(tour_id: tour_id, accessToken: accessToken,),
      backgroundColor: Colors.white,
    );
  }
}

class ProfileListBody extends StatefulWidget {
  final int tour_id;
  final String? accessToken;
  const ProfileListBody({super.key, required this.tour_id, required this.accessToken});

  @override
  State<ProfileListBody> createState() => _ProfileListBodyState();
}

class _ProfileListBodyState extends State<ProfileListBody> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _profiles = [];

  late final int tour_id;

  // 유저 검색 api
  Future<void> fetchAddUsers() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/user/',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _profiles = List<Map<String, dynamic>>.from(data).where((profile) {
            return _myInfo == null || profile['sub'] != _myInfo!['sub'];
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Map<String, dynamic>? _myInfo;

  Future<void> fetchMyInfo() async {
    final dio = Dio();
    final accessToken = widget.accessToken;
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/user/me/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _myInfo = response.data;
        });
      }
    } catch (e) {
      print('Error fetching my info: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    tour_id = widget.tour_id;
    fetchMyInfo().then((_) => fetchAddUsers());
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
            child: ListView.builder(
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                if (_searchController.text.isEmpty || profile['username']
                    .toString()
                    .contains(_searchController.text)) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.02,
                        vertical: height * 0.005
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: CircleAvatar( //유저 나타내기
                              backgroundImage: profile['profile_image_url'] != null && profile['profile_image_url'] != ""
                                  ? NetworkImage(profile['profile_image_url'])
                                  : null,
                              child: profile['profile_image_url'] == null || profile['profile_image_url'] == ""
                                  ? const Icon(Icons.person, size: 24.6)
                                  : null,
                            ),
                            title: Text(
                              profile['username'],
                              style: const TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        IconButton( //해당유저 추가 버튼
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
                                    padding: EdgeInsets.all(width*0.05),
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
                                                final accessToken = widget.accessToken;
                                                try {
                                                  final dio = Dio();
                                                  final response = await dio.post(
                                                    'http://conever.duckdns.org:8000/tour/add_traveler/',
                                                    options: Options(
                                                      headers: {
                                                        'Authorization': 'Bearer $accessToken',
                                                        'Content-Type': 'application/json',
                                                      },
                                                    ),
                                                    data: {
                                                      'add_traveler_sub': profile['sub'],
                                                      'travel_id': tour_id,
                                                    },
                                                  );
                                                  if (response.statusCode == 201) {
                                                    Navigator.pop(context);
                                                    Navigator.of(context).pushReplacement(
                                                      MaterialPageRoute(builder: (context) =>
                                                          Center(
                                                              child: Container(
                                                                width: kIsWeb ? 430 : null,
                                                                color: Colors.white,
                                                                child: MainScreen(
                                                                  accessToken: widget.accessToken,
                                                                ),
                                                              )
                                                          )
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  print('Error adding user: $e');
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
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
