import 'package:flutter/material.dart';
import '../../components/app_bar.dart';

class MyPage_QA extends StatelessWidget {
  const MyPage_QA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "자주 묻는 질문"),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
            children: [  //자주 묻는 질문 질문과 내용들 //여기는 하드코딩으로 그냥 값 안바꿀듯
              SizedBox(height: 5,),
              _QAItem(
                  "여행지 검색이 안돼요",
                  "저희 서비스는 개별 여행지 검색 기능을 제공하지 않습니다. "
                  "여행 경로는 지역 단위(예: 서울, 부산, 제주 등)로 추천되므로, "
                  "희망하시는 지역명을 입력해 주시기 바랍니다."
              ),
              _QAItem(
                  "동행자에게 여행 계획을 공유하고 싶어요 ",
                  "여행 계획 화면에서 제공되는 초대 기능을 통해 "
                  "동행자에게 카카오톡으로 여행 계획 링크를 전송하실 수 있습니다."
                  "상대방은 해당 링크를 통해 앱에 접속하여 여행 일정을 함께 확인할 수 있습니다."
              ),
            ]
        ),
      ),
    );
  }
}


Widget _QAItem(String question, String answer) {  //각 질문들 카드 구현 위젯
  return Card(
    elevation: 0,
    child: ExpansionTile(
      collapsedBackgroundColor: Color(0xFFFFFFFF),
      backgroundColor: Color(0xFFE0E0E0),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 8),
          Expanded(
            child: Text( //질문
              question,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey.shade400),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.subdirectory_arrow_right, color: Color(0xFF757575), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(  //답변
                  answer,
                  style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
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