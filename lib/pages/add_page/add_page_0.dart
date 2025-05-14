import 'package:alpha_fe/pages/add_page/add_page_1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../components/custom_alert_dialog.dart';
import '../../components/logout_by_expiration.dart';
import '../../components/proceed_button.dart';
import '../../components/app_bar.dart';
import '../../services/access_token/get_access_token_from_refresh_token.dart';

// TODO: 여행 이름과 날짜를 확정짓고 '다음' 을 눌러 여행 id가 발급된 상태에서 다른 탭으로 전환할 때 별도의 처리가 필요(무분별한 여행 id 생성 방지)
// 본 페이지에서 발급받은 tour_id 값은 최종 여행 등록에 필요하므로 모든 연결된 페이지에 인자값으로 전달됨

// 추가 탭 0번째 페이지: 여행 이름과 날짜 입력
class AddPage_0 extends StatefulWidget {
  final String? accessToken;
  final Function(int)? onFinishCreation;
  const AddPage_0({Key? key, this.onFinishCreation, required this.accessToken}) : super(key: key);

  @override
  _AddPage_0State createState() => _AddPage_0State();
}

class _AddPage_0State extends State<AddPage_0> {

  // 싱글모드 여부 확인: 콜백이 존재한다면 싱글모드로 간주
  late bool _isSingleMode;

  // 여행 이름 입력을 위한 컨트롤러
  final TextEditingController _titleController = TextEditingController();

  // 선택한 여행 날짜를 저장할 변수
  DateTimeRange? _selectedDateRange;

  // 발급받은 여행 ID를 저장할 변수
  late int _tourId;

  bool _tourRegistered = false; // 여행 생성 상태 여부 확인

  @override
  void initState() {
    super.initState();
    _isSingleMode = widget.onFinishCreation != null;
    _tourId = 0;
  }

  // 여행 날짜 선택 다이얼로그 호출
  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      locale: const Locale('ko', 'KR'),
      // 날짜 범위 제한
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            brightness: Brightness.light,
            dialogTheme: const DialogTheme(
              backgroundColor: Colors.white,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C2C2C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
              secondary: Color(0xFFFFF176), // 연노랑 (light yellow)
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2C2C2C),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // _isSingleMode일 때 1일 이상 선택 불가
      if (_isSingleMode && picked.duration.inDays > 0) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => const CustomAlertDialog(
            title: '안내',
            contentText: '지금은 1일만 선택할 수 있습니다.',
          ),
        );
        return;
      }
      // _isSingleMode가 아닐 때 15일 이상 선택 불가
      if (!_isSingleMode && picked.duration.inDays > 2) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => const CustomAlertDialog(
            title: '안내',
            contentText: '최대 3일까지 선택할 수 있습니다.',
          ),
        );
        return;
      }

      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // 입력한 여행 정보로 서버에 여행 등록 요청
  Future<void> _registerTour() async {
    final accessToken = widget.accessToken;
    final dio = Dio();
    const url = 'http://conever.duckdns.org:8000';

    // 기존 여행 중 동일한 제목과 날짜가 있는지 확인
    try {
      // 현재 사용자 이름 가져오기
      final userResponse = await dio.get(
        '$url/user/me/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        ),
      );
      final currentUsername = userResponse.data['username'];

      // 모든 여행 목록 가져오기
      final tourResponse = await dio.get(
        '$url/tour/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        ),
      );
      final List<dynamic> allPlans = tourResponse.data;

      // 현재 사용자의 여행만 필터링
      final List<dynamic> userPlans = allPlans.where((plan) {
        final List<dynamic> users = plan['user'] ?? [];
        return users.any((u) => u['username'] == currentUsername);
      }).toList();

      // 입력된 제목과 날짜 포맷 생성
      final String inputTitle = _titleController.text;
      final String inputStart = '${_selectedDateRange!.start.year.toString().padLeft(4, '0')}-${_selectedDateRange!.start.month.toString().padLeft(2, '0')}-${_selectedDateRange!.start.day.toString().padLeft(2, '0')}';
      final String inputEnd =   '${_selectedDateRange!.end.year.toString().padLeft(4, '0')}-${_selectedDateRange!.end.month.toString().padLeft(2, '0')}-${_selectedDateRange!.end.day.toString().padLeft(2, '0')}';

      // 동일한 여행이 이미 존재하는지 검사
      final bool exists = userPlans.any((plan) =>
        plan['tour_name'] == inputTitle &&
        plan['start_date'] == inputStart &&
        plan['end_date'] == inputEnd
      );

      if (exists) {
        // 이미 존재하는 여행인 경우 알림 후 종료
        await showDialog(
          context: context,
          builder: (BuildContext dialogContext) => const CustomAlertDialog(
            title: '이미 존재하는 여행입니다',
            contentText: '',
          ),
        );
        return;
      }
    } catch (e) {
      // 예외 발생 시 로깅 후 계속 진행
      print('중복 여행 확인 중 오류 발생: $e');
    }

    if (_titleController.text.isEmpty ||
        _titleController.text.length > 10 ||
        _selectedDateRange == null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => const CustomAlertDialog(
          title: '입력 오류',
          contentText: '여행 이름(10자 이내)과 날짜를 모두 입력해주세요',
        ),
      );
      return;
    }

    try {
      // 입력받은 2가지 데이터에 대해 POST 요청
      final response = await dio.post(
        '$url/tour/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
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
        _tourRegistered = true; // 여행이 생성되었음을 표시

        print(_tourId);

        if (widget.onFinishCreation != null) {
          // 콜백 함수가 주어진 경우 → AddPage_2로부터 이어지는 흐름 → onFinishCreation으로 tourId 전달하여 이후 saveTourCourse에 활용
          widget.onFinishCreation!(_tourId);
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => AddPage_1(tourId: _tourId, accessToken: widget.accessToken,)),
          );
        }
      } else {
        // 등록 실패 시
        _tourRegistered = false;
        await showDialog(
          context: context,
          builder: (BuildContext context) => const CustomAlertDialog(
            title: '등록 실패',
            contentText: '여행 등록에 실패했습니다',
          ),
        );
      }
    } catch (e) {
      // 엑세스 토큰 만료 시 리프레시 토큰을 사용해 재발급
      if (e is DioException && e.response?.statusCode == 403) {
        final bool? result = await getAccessTokenFromRefreshToken();
        if (result == false) {
          LogoutByExpiration(context);
        }
        await _registerTour();
        return;
      }
      // 요청 에러 발생 시
      _tourRegistered = false;
      await showDialog(
        context: context,
        builder: (BuildContext context) => CustomAlertDialog(
          title: '예외 발생',
          contentText: '오류 발생: $e',
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "새 여행지 추가"),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.08,
            vertical: height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 페이지 제목
              const Center(
                child: Text(
                  "여행 추가하기",
                  style: TextStyle(
                    fontSize: 26.7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: height * 0.05),

              // 여행 제목 입력 - 10글자 제한
              const Text("✏️ 여행 제목",
                  style: TextStyle(
                    fontSize: 20.5,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: height * 0.01),
              SizedBox(
                height: height * 0.06,
                child: TextField(
                  controller: _titleController,
                  maxLength: 10,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "여행에 대한 정보를 간단한 제목으로 지어보세요",
                    hintStyle: const TextStyle(
                      fontSize: 14.3,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: "",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.03,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.005),
              const Text("• 한글, 영문, 특수기호 구분없이 10자 이내로 입력",
                  style: TextStyle(fontSize: 12.3, color: Colors.grey)),
              const Text("• 결정 후 수정할 수 없으니 신중히 정해주세요",
                  style: TextStyle(fontSize: 12.3, color: Colors.grey)),

              SizedBox(height: height * 0.05),

              // 여행 날짜 입력 - material.dart의 DateRangePicker 사용
              const Text("✏️ 여행 날짜",
                  style: TextStyle(
                    fontSize: 20.5,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // 날짜 표시 필드
                  Expanded(
                    child: SizedBox(
                      height: height * 0.06,
                      child: TextField(
                        readOnly: true,
                        cursorColor: const Color(0xFF2C2C2C),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: _selectedDateRange == null
                              ? ""
                              : "${_selectedDateRange!.start.year}.${_selectedDateRange!.start.month.toString().padLeft(2, '0')}.${_selectedDateRange!.start.day.toString().padLeft(2, '0')} ~ "
                                "${_selectedDateRange!.end.year}.${_selectedDateRange!.end.month.toString().padLeft(2, '0')}.${_selectedDateRange!.end.day.toString().padLeft(2, '0')}",
                          hintStyle: const TextStyle(
                            fontSize: 12.3,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.02,
                            horizontal: width * 0.03,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: width * 0.02),

                  // 날짜 선택 버튼 - showDateRangePicker 호출
                  SizedBox(
                    height: height * 0.058,
                    width: width * 0.14,
                    child: ElevatedButton(
                      onPressed: _selectDateRange,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "🗓️",
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.005),

              // 접속 경로에 따라 경고 메세지 다르게
              _isSingleMode
                  ? Text("• 지금은 1일만 선택할 수 있습니다",
                  style: TextStyle(fontSize: 12.3, color: Colors.red.shade500))
                  : Text("• 지금은 3일만 선택할 수 있습니다",
                  style: TextStyle(fontSize: 12.3, color: Colors.red.shade500)),

              SizedBox(height: height * 0.073,),
              // 새 여행 만들기 버튼 - 여행 id 발급 및 행정구역 선택 페이지로 이동
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.106, vertical: height * 0.086),
                child: Center(
                  child: ProceedButton(
                    size_w: width * 0.8,
                    size_h: height * 0.06,
                    text: "새 여행 만들기",
                    fontSize_: 18.5,
                    fontWeight_: FontWeight.bold,
                    onTap: _registerTour,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
