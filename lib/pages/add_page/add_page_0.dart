import 'package:alpha_fe/pages/add_page/add_page_1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../components/app_bar.dart';

// TODO: 여행 이름과 날짜를 확정짓고 '다음' 을 눌러 여행 id가 발급된 상태에서 다른 탭으로 전환할 때 별도의 처리가 필요(무분별한 여행 id 생성 방지)
// 본 페이지에서 발급받은 tour_id 값은 최종 여행 등록에 필요하므로 모든 연결된 페이지에 인자값으로 전달됨

// 추가 탭 0번째 페이지: 여행 이름과 날짜 입력
class AddPage_0 extends StatefulWidget {

  @override
  _AddPage_0State createState() => _AddPage_0State();
}

class _AddPage_0State extends State<AddPage_0> {

  // 여행 이름 입력을 위한 컨트롤러
  final TextEditingController _titleController = TextEditingController();

  // 선택한 여행 날짜를 저장할 변수
  DateTimeRange? _selectedDateRange;

  // 발급받은 여행 ID를 저장할 변수
  late int _tourId;

  // 여행 날짜 선택 다이얼로그 호출
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365*5)),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // 입력한 여행 정보로 서버에 여행 등록 요청
  Future<void> _registerTour() async {
    if (_titleController.text.isEmpty || _selectedDateRange == null) {
      // 입력값이 없으면 알림 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('여행 이름과 날짜를 모두 입력해주세요')),
      );
      return;
    }

    final dio = Dio();
    final url = 'http://conever.duckdns.org:8000/tour/';

    try {
      // 입력받은 2가지 데이터에 대해 POST 요청
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${dotenv.env['KAKAO_ACCESS_TOKEN']}'
          }
        ),
        data: {
          'tour_name': _titleController.text,
          'start_date': '${_selectedDateRange!.start.year}-${_selectedDateRange!.start.month.toString().padLeft(2, '0')}-${_selectedDateRange!.start.day.toString().padLeft(2, '0')}',
          'end_date': '${_selectedDateRange!.end.year}-${_selectedDateRange!.end.month.toString().padLeft(2, '0')}-${_selectedDateRange!.end.day.toString().padLeft(2, '0')}',
        },
      );

      if (response.statusCode == 201) {
        // 성공적으로 tour_id 발급 시 다음 페이지로 이동
        setState(() {
          _tourId = response.data['id'];
        });

        print(_tourId);

        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => AddPage_1(tourId: _tourId)),
        );
      } else {
        // 등록 실패 시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('여행 등록에 실패했습니다')),
        );
      }
    } catch (e) {
      // 요청 에러 발생 시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('여행 정보 입력')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 여행 이름 입력 필드
            Text('여행 이름', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            TextField(
              controller: _titleController,
              maxLength: 10,
              decoration: InputDecoration(
                hintText: '여행 이름을 입력하세요',
              ),
            ),

            SizedBox(height: 20),

            // 여행 날짜 선택 버튼
            Text('여행 날짜', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            SizedBox(height: 8),

            ElevatedButton(
              onPressed: _selectDateRange,
              child: Text(
                _selectedDateRange == null
                  ? '여행 날짜 선택'
                  : '${_selectedDateRange!.start.year}.${_selectedDateRange!.start.month}.${_selectedDateRange!.start.day} ~ ${_selectedDateRange!.end.year}.${_selectedDateRange!.end.month}.${_selectedDateRange!.end.day}'
              ),
            ),

            Spacer(),

            // 다음 버튼 - 입력받은 데이터로 tour_id 발급 및 행정구역 선택 페이지로 전환
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerTour,
                child: Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
