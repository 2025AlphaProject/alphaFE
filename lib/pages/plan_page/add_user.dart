import 'package:alpha_fe/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:alpha_fe/components/app_bar.dart';
import 'package:alpha_fe/main.dart';

class ProfileListPage extends StatelessWidget {
  final int tour_id;
  const ProfileListPage({super.key, required this.tour_id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "친구추가"),
      body: ProfileListBody(tour_id: tour_id),
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
  List<Map<String, dynamic>> _profiles = [];

  late final int tour_id;
  final String accessToken =  dotenv.env['KAKAO_ACCESS_TOKEN']!;

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
          _profiles = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    tour_id = widget.tour_id;
    fetchAddUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration( //원하는 유저 검색가능
              hintText: '검색...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: CircleAvatar( //유저 나타내기
                            backgroundImage: profile['profile_image_url'] != null && profile['profile_image_url'] != ""
                                ? NetworkImage(profile['profile_image_url'])
                                : null,
                            child: profile['profile_image_url'] == null || profile['profile_image_url'] == ""
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(profile['username']),
                        ),
                      ),
                      IconButton( //해당유저 추가 버튼
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('추가 확인'),
                                content: Text('이 유저를 추가하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('취소'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try { //유저추가 api
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
                                          Navigator.pop(context); // close the dialog
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (context) => MainScreen(
                                              accessToken: accessToken,
                                            )), //처음으로 되돌아감
                                          );
                                        }
                                      } catch (e) {
                                        print('Error adding user: $e');
                                      }
                                    },
                                    child: const Text('확인'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }
}
