import 'package:alpha_fe/pages/add_page/add_page_1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../components/proceed_button.dart';
import '../../components/app_bar.dart';

// TODO: 여행 이름과 날짜를 확정짓고 '다음' 을 눌러 여행 id가 발급된 상태에서 다른 탭으로 전환할 때 별도의 처리가 필요(무분별한 여행 id 생성 방지)
// 본 페이지에서 발급받은 tour_id 값은 최종 여행 등록에 필요하므로 모든 연결된 페이지에 인자값으로 전달됨

// 추가 탭 0번째 페이지: 여행 이름과 날짜 입력
class AddPage_0 extends StatefulWidget {
  final String? accessToken;
  final Function(int)? onFinishCreation;

  const AddPage_0({Key? key, required this.accessToken, this.onFinishCreation}) : super(key: key);

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
      locale: const Locale('ko', 'KR'),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365*5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF2C2C2C),
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2C2C2C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            dialogBackgroundColor: Colors.white,
            hintColor: Color(0xFFB5B5B5),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // 입력한 여행 정보로 서버에 여행 등록 요청
  Future<void> _registerTour() async {
    if (_titleController.text.isEmpty ||
        _titleController.text.length > 10 ||
        _selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('여행 이름(10자 이내)과 날짜를 모두 입력해주세요')),
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
            'Authorization': 'Bearer ${widget.accessToken}'
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

        if (widget.onFinishCreation != null) {
          // 콜백 함수가 주어진 경우 → AddPage_2로부터 이어지는 흐름 → onFinishCreation으로 tourId 전달하여 이후 saveTourCourse에 활용
          widget.onFinishCreation!(_tourId);
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => AddPage_1(tourId: _tourId)),
          );
        }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "새 여행지 추가"),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 페이지 제목
            Center(
              child: Text(
                "여행 추가하기",
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            // 여행 제목 입력 - 10글자 제한
            Text("✏️ 여행 제목",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              height: screenHeight * 0.06,
              child: TextField(
                controller: _titleController,
                maxLength: 10,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "여행에 대한 정보를 간단한 제목으로 지어보세요",
                  hintStyle: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.03,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text("• 한글, 영문, 특수기호 구분없이 10자 이내로 입력",
                style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey)),
            Text("• 결정 후 수정할 수 없으니 신중히 정해주세요",
                style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey)),

            SizedBox(height: screenHeight * 0.05),

            // 여행 날짜 입력 - material.dart의 DateRangePicker 사용
            Text("✏️ 여행 날짜",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // 날짜 표시 필드
                Expanded(
                  child: SizedBox(
                    height: screenHeight * 0.06,
                    child: TextField(
                      readOnly: true,
                      cursorColor: Color(0xFF2C2C2C),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: _selectedDateRange == null
                            ? ""
                            : "${_selectedDateRange!.start.year}.${_selectedDateRange!.start.month.toString().padLeft(2, '0')}.${_selectedDateRange!.start.day.toString().padLeft(2, '0')} ~ "
                              "${_selectedDateRange!.end.year}.${_selectedDateRange!.end.month.toString().padLeft(2, '0')}.${_selectedDateRange!.end.day.toString().padLeft(2, '0')}",
                        hintStyle: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.03,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: screenWidth * 0.02),

                // 날짜 선택 버튼 - showDateRangePicker 호출
                SizedBox(
                  height: screenHeight * 0.058,
                  width: screenWidth * 0.14,
                  child: ElevatedButton(
                    onPressed: _selectDateRange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                    ),
                    child: Text(
                      "🗓️",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // 새 여행 만들기 버튼 - 여행 id 발급 및 행정구역 선택 페이지로 이동
            Center(
              child: ProceedButton(
                size_w: screenWidth * 0.8,
                size_h: screenHeight * 0.06,
                text: "새 여행 만들기",
                fontSize_: screenWidth * 0.045,
                fontWeight_: FontWeight.bold,
                padding_: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.012,
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                ),
                onTap: _registerTour,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
