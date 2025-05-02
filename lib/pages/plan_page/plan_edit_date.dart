import 'package:alpha_fe/pages/plan_page/plan_page_2.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:dio/dio.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../mainscreen.dart';

class planEditDate extends StatefulWidget {
  final String startDate;
  final String endDate;
  final int tour_id;
  final String? accessToken;

  const planEditDate({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.tour_id,
    required this.accessToken,
  });

  @override
  State<planEditDate> createState() => _planEditDateState();
}

class _planEditDateState extends State<planEditDate> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _selectedDay;
  late DateTime _focusedDay;
  bool _isSelectionCompleted = false;
  late DateTime _initialStartDate;
  late DateTime _initialEndDate;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  @override
  void initState() {
    super.initState();
    _initialStartDate = DateTime.parse(widget.startDate); // 원래 날짜
    _initialEndDate = DateTime.parse(widget.endDate); // 원래 날짜
    _rangeStart = _initialStartDate; //바뀔날짜
    _rangeEnd = _initialEndDate; //바뀔날짜
    _focusedDay = _rangeStart!;
    _selectedDay = null;
    _isSelectionCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "날짜수정 앱바 영역"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            TableCalendar( //달력띄우기와 그쪽 디자인, 선택한 날짜부분 디자인 영역
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              availableCalendarFormats: const {
                CalendarFormat.month : 'Month',
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: _rangeSelectionMode,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: Colors.blue.withOpacity(0.3),
                rangeStartDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                weekendTextStyle: const TextStyle(
                  color: Colors.red,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.red),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                //여기부터가 선택로직
                setState(() {
                  if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
                    _rangeStart = selectedDay; //첫선택 이거나 이미 날짜 두개 선택되어있는테 선택 다시한거면 시작날짜
                    _rangeEnd = null;
                    _isSelectionCompleted = false;
                  } else if (_rangeStart != null && _rangeEnd == null) {
                    if (selectedDay.isBefore(_rangeStart!)) { //두번째 선택날짜가 시작날짜 이전이면 시작날짜로 생각
                      _rangeStart = selectedDay;
                      _rangeEnd = null;
                      _isSelectionCompleted = false;
                    } else { //이후면 날짜 선택 완료
                      _rangeEnd = selectedDay;
                      _isSelectionCompleted = true;
                    }
                  }
                  _focusedDay = focusedDay;
                  _selectedDay = selectedDay;
                });
              },
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _rangeStart = start;
                  _rangeEnd = end;
                  _focusedDay = focusedDay;
                  _rangeSelectionMode = RangeSelectionMode.toggledOn;
                });
              },
              calendarBuilders: CalendarBuilders( //오늘 나타내는 디자인쪽
                todayBuilder: (context, date, _) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '오늘',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isSelectionCompleted &&
                (_rangeStart != null && _rangeEnd != null) &&
                !(_rangeStart!.isAtSameMomentAs(_initialStartDate) && _rangeEnd!.isAtSameMomentAs(_initialEndDate)))
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog( //shodialog 누르면 나타나기
                            title: Text('날짜 수정 확인'),
                            content: Text('선택한 기간으로 여행 일정을 수정하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('취소'),
                              ),
                              ElevatedButton(
                                onPressed: () async { //날짜 수정 api
                                  try {
                                    final dio = Dio();
                                    final response = await dio.put(
                                      'http://conever.duckdns.org:8000/tour/${widget.tour_id}/',
                                      data: {
                                        'start_date': _rangeStart!.toIso8601String().split('T').first,
                                        'end_date': _rangeEnd!.toIso8601String().split('T').first,
                                      },
                                      options: Options(
                                        headers: {
                                          'Authorization': 'Bearer ${widget.accessToken}',
                                          'Content-Type': 'application/json',
                                        },
                                      ),
                                    );

                                    if (response.statusCode == 200) {
                                      if (!mounted) return; // 안전 체크 추가

                                      Navigator.of(context).pop(); // 다이얼로그 닫기
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => MainScreen(
                                            accessToken: widget.accessToken,
                                          ), // 처음으로 다시 돌아가기
                                        ),
                                      );
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
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "${_rangeStart!.year}.${_rangeStart!.month}.${_rangeStart!.day} - ${_rangeEnd!.month}.${_rangeEnd!.day} / 수정",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
