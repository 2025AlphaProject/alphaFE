import 'package:alpha_fe/pages/plan_page/plan_page.dart';
import 'package:flutter/material.dart';
import 'package:alpha_fe/pages/plan_page/plan_edit_date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
            const Text("편집", style: TextStyle(fontWeight: FontWeight.bold)),
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
            _EditMenu( //여행날짜 수정
              text: "여행날짜 수정",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => planEditDate(
                      startDate: startDate,
                      endDate: endDate,
                      tour_id: tour_id,
                    ),
                  ),
                ).then((result) {
                  if (result == 'updated') {
                    Navigator.pop(context, 'updated');
                  }
                });
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
  final String accessToken =  dotenv.env['KAKAO_ACCESS_TOKEN']!;

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
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          title: const Text("여행제목 수정"),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: "새 여행제목 입력",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () async { //수정한 여행 제목 저장
                  try {
                    final dio = Dio();
                    final response = await dio.put(
                      'http://conever.duckdns.org:8000/tour/${widget.tour_id}/',
                      data: {
                        'tour_name' :_nameController.text,
                      },
                      options: Options(
                        headers: {
                          'Authorization': 'Bearer $accessToken',
                          'Content-Type': 'application/json',
                        },
                      ),
                    );

                    if (response.statusCode == 200) {
                      if (!mounted) return; // 안전 체크 추가
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    } else { //TODO: 오류뜰때 어케할지 수정해야함
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('수정 실패: ${response.statusCode}')),
                      );
                    }
                  } catch (e) { //TODO: 오류뜰때 어케할지 수정해야함
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('오류 발생: $e')),
                    );
                  }
                },
              child: const Text("확인"),
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
  final String accessToken =  dotenv.env['KAKAO_ACCESS_TOKEN']!;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text('여행 삭제'),
          content: Text('이 여행을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
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
                      SnackBar(content: Text('수정 실패: ${response.statusCode}')),
                    );
                  }
                } catch (e) { //TODO: 오류뜰때 어케할지 수정해야함
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류 발생: $e')),
                  );
                }
              },
              child: Text('삭제',style: TextStyle(color: Colors.red,)),
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
  final String accessToken =  dotenv.env['KAKAO_ACCESS_TOKEN']!;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text('여행 계획 초기화'),
          content: Text('이 여행 경로를 초기화하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
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
                      SnackBar(content: Text('수정 실패: ${response.statusCode}')),
                    );
                  }
                } catch (e) {//TODO: 오류뜰때 어케할지 수정해야함
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류 발생: $e')),
                  );
                }
              },
              child: Text('초기화',style: TextStyle(color: Colors.red,)),
            ),
          ],
        ),
      ),
    );
  }
}
