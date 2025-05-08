import 'package:alpha_fe/components/auth_token_handler.dart';
import 'package:alpha_fe/components/token_controller.dart';
import 'package:alpha_fe/mainscreen.dart';
import 'package:alpha_fe/pages/plan_page/plan_page.dart';
import 'package:alpha_fe/pages/plan_page/plan_page_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alpha_fe/pages/plan_page/plan_edit_date.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/main.dart';

import 'logout_by_expiration.dart';

// 전체적인 편집관련
class TravelEditMenu extends StatelessWidget {
  final String? accessToken;
  final String startDate;
  final String endDate;
  final int tour_id;
  final String tourName;
  final VoidCallback? onRefresh;

  const TravelEditMenu({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.tour_id,
    required this.tourName,
    required this.onRefresh,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.066,
          vertical: height * 0.029
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("여행 경로 편집", style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.05)),
            SizedBox(height: height * 0.029),
            _EditMenu( //여행 제목 수정
              text: "여행제목 수정",
              icon: Icons.edit,
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => Center(
                    child: EditTourNameDialog(
                      tourName: tourName,
                      tour_id: tour_id,
                      onRefresh: onRefresh,
                      accessToken: accessToken,
                    ),
                  ),
                );
              },
            ),
            _EditMenu( //여행경로 삭제(코스 다 삭제 하기)
              text: "여행경로 삭제",
              icon: Icons.remove_road,
              onTap: () {
                EditState.showEditButton = true;
                print(EditState.showEditButton);
                if ( onRefresh != null) {
                  onRefresh!(); // 콜백 호출
                }
                Navigator.pop(context,true);
              },
            ),

            _EditMenu(  //여행 자체를 삭제
              text: "여행 삭제",
              icon: Icons.delete,
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => Center(child: DeleteTour(tour_id: tour_id, accessToken: accessToken,))
                );
              },
            ),
            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }
}

// 단일 편집메뉴 - 수정할 각각 버튼틀
class _EditMenu extends StatelessWidget {
  final String text;
  final bool isDestructive;
  final VoidCallback onTap;
  final IconData? icon;

  const _EditMenu({
    super.key,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.025,
          horizontal: width * 0.02,
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, color: isDestructive ? Colors.red : Colors.black),
            if (icon != null)
              SizedBox(width: width * 0.019),
            Text(
              text,
              style: TextStyle(
                fontSize: 18.5,
                fontWeight: isDestructive ? FontWeight.bold : FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 여행제목 수정 다이얼로그
class EditTourNameDialog extends StatefulWidget {
  final String tourName;
  final int tour_id;
  final VoidCallback? onRefresh;
  final String? accessToken;

  const EditTourNameDialog({
    Key? key,
    required this.tourName,
    required this.tour_id,
    this.onRefresh,
    required this.accessToken,
  }) : super(key: key);

  @override
  _EditTourNameDialogState createState() => _EditTourNameDialogState();
}

class _EditTourNameDialogState extends State<EditTourNameDialog> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tourName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          backgroundColor: const Color(0xFFF9F9F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "여행제목 수정",
            style: TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "새 여행제목 입력",
                  hintStyle: TextStyle(fontSize: 16.5, color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.014),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF9F9F9),
              ),
              onPressed: () {
                Navigator.pop(context); // 취소
              },
              child: const Text("취소", style: TextStyle(fontSize: 16.5, color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.014),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  final dio = Dio();
                  final accessToken = widget.accessToken;
                  final response = await dio.put(
                    'http://conever.duckdns.org:8000/tour/${widget.tour_id}/',
                    data: {
                      'tour_name': _nameController.text,
                    },
                    options: Options(
                      headers: {
                        'Authorization': 'Bearer $accessToken',
                        'Content-Type': 'application/json',
                      },
                    ),
                  );
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });

                  if (response.statusCode == 200) {
                    if (!mounted) return; // 안전 체크 추가
                    EditState.showEditButton = false;
                    widget.onRefresh?.call();
                    Navigator.pop(context,true); // 다이얼로그 닫기
                  }

                  else if (response.statusCode == 401) {
                    LogoutByExpiration(context);
                  }

                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '수정 실패: ${response.statusCode}',
                          style: const TextStyle(fontSize: 16.5),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (e is DioException && e.response?.statusCode == 403) {
                    final bool? result = await getAccessTokenFromRefreshToken();
                    if (result == false) {
                      LogoutByExpiration(context);
                    }
                    // Retry the request after refreshing the token
                    final dio = Dio();
                    final accessToken = widget.accessToken;
                    final retryResponse = await dio.put(
                      'http://conever.duckdns.org:8000/tour/${widget.tour_id}/',
                      data: {
                        'tour_name': _nameController.text,
                      },
                      options: Options(
                        headers: {
                          'Authorization': 'Bearer $accessToken',
                          'Content-Type': 'application/json',
                        },
                      ),
                    );

                    if (!mounted) return;
                    setState(() {
                      _isLoading = false;
                    });

                    if (retryResponse.statusCode == 200) {
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '재시도 실패: ${retryResponse.statusCode}',
                            style: const TextStyle(fontSize: 16.5),
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '오류 발생: $e',
                        style: const TextStyle(fontSize: 16.5),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "확인",
                style: TextStyle(
                  fontSize: 16.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// 여행 삭제
class DeleteTour extends StatefulWidget {
  final String? accessToken;
  final int tour_id;

  const DeleteTour({Key? key,
    required this.tour_id, required this.accessToken,
  }) : super(key: key);

  @override
  State<DeleteTour> createState() => _DeleteTourState();
}

class _DeleteTourState extends State<DeleteTour> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          backgroundColor: const Color(0xFFF9F9F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            '여행 삭제',
            style: TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            '이 여행을 삭제하시겠습니까?',
            style: TextStyle(fontSize: 16.5, color: Colors.black),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF9F9F9),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(fontSize: 16.5, color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                try {
                  final dio = Dio();
                  final accessToken = widget.accessToken;
                  final response = await dio.delete(
                    'http://conever.duckdns.org:8000/tour/${widget.tour_id}/',
                    options: Options(
                      headers: {
                        'Authorization': 'Bearer $accessToken',
                        'Content-Type': 'application/json',
                      },
                    ),
                  );

                  if (response.statusCode == 204) {
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MainScreen(accessToken: accessToken,)),
                    );
                  } else if (response.statusCode == 401) {
                    LogoutByExpiration(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '수정 실패: ${response.statusCode}',
                          style: const TextStyle(fontSize: 16.5),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '오류 발생: $e',
                        style: const TextStyle(fontSize: 16.5),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// 여행 경로 삭제(건들ㄴㄴ)
class DeleteCourse extends StatefulWidget {
  final String? accessToken;
  final int tour_id;
  final String target_date;
  final VoidCallback? onRefresh;

  const DeleteCourse({Key? key,
    required this.tour_id,
    required this.target_date,
    this.onRefresh, required this.accessToken
  }) : super(key: key);

  @override
  State<DeleteCourse> createState() => _DeleteCourseState();
}

class _DeleteCourseState extends State<DeleteCourse> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          backgroundColor: const Color(0xFFF9F9F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            '여행 경로 삭제',
            style: TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.target_date,
                style: const TextStyle(fontSize: 24.6, fontWeight: FontWeight.bold),
              ),
              const Text(
                  "의 경로를 삭제하겠습니까?", style: TextStyle(
                fontSize: 16.5
              ),
              )
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF9F9F9),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(fontSize: 16.5, color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async { //여행경로 삭제하기
                try {
                  final dio = Dio();
                  final accessToken = widget.accessToken;
                  final response = await dio.delete(
                    'http://conever.duckdns.org:8000/tour/course/${widget.tour_id}/',
                    data: {
                      "target_date": widget.target_date
                    },
                    options: Options(
                      headers: {
                        'Authorization': 'Bearer $accessToken',
                        'Content-Type': 'application/json',
                      },
                    ),
                  );
                  if (response.statusCode == 204) {
                    if (!mounted) return; // 안전 체크 추가
                    EditState.showEditButton = false;
                    widget.onRefresh?.call();
                    Navigator.pop(context,true); // 다이얼로그 닫기
                  }

                  else if (response.statusCode == 401) {
                    LogoutByExpiration(context);
                  }

                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '수정 실패: ${response.statusCode}',
                          style: const TextStyle(fontSize: 16.5),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '오류 발생: $e',
                        style: const TextStyle(fontSize: 16.5),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}