import 'package:alpha_fe/pages/plan_page/plan_page.dart';
import 'package:flutter/material.dart';
import 'package:alpha_fe/pages/plan_page/plan_edit_date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/pages/plan_page/plan_page.dart';

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
        padding:
        const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("편집", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _EditMenu(
              text: "여행경로 삭제",
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => DeleteCourse(tour_id: tour_id)
                );
              },
            ),
            _EditMenu(
              text: "여행제목 수정",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => EditTourNameDialog(tourName: tourName, tour_id: tour_id,),
                );
              },
            ),
            _EditMenu(
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
                );
              },
            ),
            _EditMenu(
              text: "여행 삭제",
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => DeleteTour(tour_id: tour_id)
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 단일 편집메뉴
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
        Navigator.pop(context); // 선택 후 닫기
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
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
    return AlertDialog(
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
          onPressed: () async {
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('수정 실패: ${response.statusCode}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('오류 발생: $e')),
                );
              }
            },
          child: const Text("확인"),
        ),
      ],
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
    return AlertDialog(
      title: Text('여행 삭제'),
      content: Text('이 여행을 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PlanPage(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('수정 실패: ${response.statusCode}')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('오류 발생: $e')),
              );
            }
          },
          child: Text('삭제',style: TextStyle(color: Colors.red,)),
        ),
      ],
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
    return AlertDialog(
      title: Text('여행 계획 초기화'),
      content: Text('이 여행 경로를 초기화하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PlanPage(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('수정 실패: ${response.statusCode}')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('오류 발생: $e')),
              );
            }
          },
          child: Text('초기화',style: TextStyle(color: Colors.red,)),
        ),
      ],
    );
  }
}
