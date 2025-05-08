import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';

class MyPage_QA extends StatelessWidget {
  const MyPage_QA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "자주 묻는 질문"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.021, vertical: height * 0.009),
        child: ListView(
            children: [  //자주 묻는 질문 질문과 내용들 //여기는 하드코딩으로 그냥 값 안바꿀듯
              SizedBox(height: height * 0.006,),
              _QAItem(
                  "여행지 검색이 안돼요",
                  "저희 서비스는 개별 여행지 검색 기능을 제공하지 않습니다."
                      "여행 경로는 지역 단위(예: 강남구, 성북구, 중구 등) 로 추천되므로,"
                      "희망하시는 지역명을 입력해 주시기 바랍니다."
              , width, height),
              _QAItem(
                  "동행자에게 여행 계획을 공유하고 싶어요",
                  "동행자분께서 저희 앱에 가입하신 경우,"
                  "여행 계획 화면에서 ‘여행자 초대’ 기능을 통해 여행 일정을 공유하실 수 있습니다.."
              , width, height),
              _QAItem(
                  "생성된 미션이 없어요",
                  "미션은 매일 초기화되며,"
                  "당일 일정이 포함된 여행 경로에 한해 자동으로 생성됩니다."
                  "오늘 날짜에 해당하는 여행이 등록되어 있는지 확인해주시기 바랍니다."
                  , width, height),
            ]
        ),
      ),
    );
  }
}


Widget _QAItem(String question, String answer, double height, double width) {  //각 질문들 버튼 구현 위젯
  return Card(
    elevation: 0,
    child: ExpansionTile(
      collapsedBackgroundColor: const Color(0xFFFFFFFF),
      backgroundColor: const Color(0xFFE0E0E0),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: width * 0.02),
          Expanded(
            child: Text( //질문
              question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey.shade400),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.038, vertical: height * 0.018),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.subdirectory_arrow_right, color: Color(0xFF757575), size: 20),
              SizedBox(width: width * 0.015),
              Expanded(
                child: Text(  //답변
                  answer,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF000000)),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}