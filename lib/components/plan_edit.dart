import 'package:alpha_fe/components/auth_token_handler.dart';
import 'package:alpha_fe/mainscreen.dart';
import 'package:alpha_fe/pages/plan_page/plan_page.dart';
import 'package:flutter/material.dart';
import 'package:alpha_fe/pages/plan_page/plan_edit_date.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/main.dart';

// 전체적인 편집관련
class TravelEditMenu extends StatelessWidget {
  final String startDate;
  final String endDate;
  final int tour_id;
  final String tourName;

  const TravelEditMenu({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.tour_id,
    required this.tourName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.066,
          vertical: MediaQuery.of(context).size.height * 0.029
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("편집", style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width * 0.04)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.029),
            _EditMenu( //여행경로 삭제(코스 다 삭제 하기)
              text: "여행경로 삭제",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Center(child: DeleteCourse(tour_id: tour_id)),
                );
              },
            ),
            _EditMenu( //여행 제목 수정
              text: "여행제목 수정",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Center(child: EditTourNameDialog(tourName: tourName, tour_id: tour_id,)),
                );
              },
            ),
            _EditMenu(
              text: "여행날짜 수정",
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => Center(
                    child: EditTourDateDialog(
                      startDate: startDate,
                      endDate: endDate,
                      tour_id: tour_id,
                    ),
                  ),
                );

                if (result == true) {
                  Navigator.pop(context); // Close the TravelEditMenu if date was updated
                }
              },
            ),
            _EditMenu(  //여행 자체를 삭제
              text: "여행 삭제",
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Center(child: DeleteTour(tour_id: tour_id))
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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

  const _EditMenu({
    super.key,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.025,
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.044,
              color: isDestructive ? Colors.red : Colors.black,
            ),
          ),
        ),
    );
  }
}

// 여행제목 수정 다이얼로그
class EditTourNameDialog extends StatefulWidget {
  final String tourName;
  final int tour_id;


  const EditTourNameDialog({Key? key,
    required this.tourName,
    required this.tour_id
  }) : super(key: key);

  @override
  _EditTourNameDialogState createState() => _EditTourNameDialogState();
}

class _EditTourNameDialogState extends State<EditTourNameDialog> {
  late TextEditingController _nameController;
  late final String accessToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tourName);
    _initToken();
  }

  Future<void> _initToken() async {
    accessToken = (await getAccessTokenFromRefreshToken()) ?? '';
  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text("여행제목 수정", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "새 여행제목 입력",
                  hintStyle: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소
              },
              child: Text("취소", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  final dio = Dio();
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
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '수정 실패: ${response.statusCode}',
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '오류 발생: $e',
                        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                      ),
                    ),
                  );
                }
              },
              child: Text("확인", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
          ],
        ),
      ),
    );
  }
}


// 여행 삭제
class DeleteTour extends StatefulWidget {
  final int tour_id;

  const DeleteTour({Key? key,
    required this.tour_id,
  }) : super(key: key);

  @override
  State<DeleteTour> createState() => _DeleteTourState();
}

class _DeleteTourState extends State<DeleteTour> {
  late final String accessToken;

  @override
  void initState() {
    super.initState();
    _initToken();
  }

  Future<void> _initToken() async {
    accessToken = (await getAccessTokenFromRefreshToken()) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text('여행 삭제', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
          content: Text('이 여행을 삭제하시겠습니까?', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
            ElevatedButton(
              onPressed: () async { //내 여행 삭제하기
                try {
                  final dio = Dio();
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
                    if (!mounted) return; // 안전 체크 추가
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  } else { //TODO: 오류뜰때 어케할지 수정해야함
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '수정 실패: ${response.statusCode}',
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                        ),
                      ),
                    );
                  }
                } catch (e) { //TODO: 오류뜰때 어케할지 수정해야함
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '오류 발생: $e',
                        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                      ),
                    ),
                  );
                }
              },
              child: Text('삭제',style: TextStyle(color: Colors.red, fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
          ],
        ),
      ),
    );
  }
}


// 여행 경로 삭제
class DeleteCourse extends StatefulWidget {
  final int tour_id;

  const DeleteCourse({Key? key,
    required this.tour_id,
  }) : super(key: key);

  @override
  State<DeleteCourse> createState() => _DeleteCourseState();
}

class _DeleteCourseState extends State<DeleteCourse> {
  late final String accessToken;

  @override
  void initState() {
    super.initState();
    _initToken();
  }

  Future<void> _initToken() async {
    accessToken = (await getAccessTokenFromRefreshToken()) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text('여행 계획 초기화', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
          content: Text('이 여행 경로를 초기화하시겠습니까?', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
            ElevatedButton(
              onPressed: () async { //여행경로 삭제하기
                try {
                  final dio = Dio();
                  final response = await dio.delete(
                    'http://conever.duckdns.org:8000/tour/course/${widget.tour_id}/',
                    options: Options(
                      headers: {
                        'Authorization': 'Bearer $accessToken',
                        'Content-Type': 'application/json',
                      },
                    ),
                  );
                  if (response.statusCode == 204) {
                    if (!mounted) return; // 안전 체크 추가
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  } else { //TODO: 오류뜰때 어케할지 수정해야함
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '수정 실패: ${response.statusCode}',
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                        ),
                      ),
                    );
                  }
                } catch (e) {//TODO: 오류뜰때 어케할지 수정해야함
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '오류 발생: $e',
                        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                      ),
                    ),
                  );
                }
              },
              child: Text('초기화',style: TextStyle(color: Colors.red, fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
          ],
        ),
      ),
    );
  }
}


// 여행날짜 수정 다이얼로그
class EditTourDateDialog extends StatefulWidget {
  final String startDate;
  final String endDate;
  final int tour_id;

  const EditTourDateDialog({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.tour_id,
  }) : super(key: key);

  @override
  _EditTourDateDialogState createState() => _EditTourDateDialogState();
}

class _EditTourDateDialogState extends State<EditTourDateDialog> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  final accessToken = getAccessTokenFromRefreshToken();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController(text: widget.startDate);
    _endDateController = TextEditingController(text: widget.endDate);
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text("여행날짜 수정", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _startDateController,
                decoration: InputDecoration(
                  hintText: "시작 날짜 (YYYY-MM-DD)",
                  hintStyle: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _endDateController,
                decoration: InputDecoration(
                  hintText: "종료 날짜 (YYYY-MM-DD)",
                  hintStyle: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                ),
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    final resolvedToken = await accessToken;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => planEditDate(
                          startDate: _startDateController.text,
                          endDate: _endDateController.text,
                          tour_id: widget.tour_id,
                          accessToken: resolvedToken,
                        ),
                      ),
                    ).then((result) {
                      if (result != null && result is Map<String, String>) {
                        setState(() {
                          _startDateController.text = result['start_date'] ?? _startDateController.text;
                          _startDateController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _startDateController.text.length),
                          );
                          _endDateController.text = result['end_date'] ?? _endDateController.text;
                          _endDateController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _endDateController.text.length),
                          );
                        });
                      }
                    });
                  },
                  icon: Icon(Icons.calendar_month),
                  label: Text("달력으로 선택"),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소
              },
              child: Text("취소", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  final dio = Dio();
                  final response = await dio.put(
                    'http://conever.duckdns.org:8000/tour/${widget.tour_id}/',
                    data: {
                      'start_date': _startDateController.text,
                      'end_date': _endDateController.text,
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
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '수정 실패: ${response.statusCode}',
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '오류 발생: $e',
                        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                      ),
                    ),
                  );
                }
              },
              child: Text("확인", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
            ),
          ],
        ),
      ),
    );
  }
}