import 'package:flutter/material.dart';
import '../../components/app_bar.dart';

class Mission_Page extends StatelessWidget {
  const Mission_Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "미션페이지"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 44),
              Center(                //미션 진행도 원형 상태바
                child: SizedBox(
                  height: 150, width: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 9 / 10,  //나중에 이부분 미션 개수랑 성공 여부에 따라 값 달라질 부분
                        strokeWidth: 20,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
                      ),
                      Center(
                        child: Text(
                          '9/10', // 나중에 미션 개수랑 성공 여부에 따락 값 달라질 부분
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Column(            //미션 및 설명들
                children: [ //이것도 미션 리스트 어케 받아오냐에 따라 달라짐
                  _missionItem(false, "미션 ",["내용1","내용2"]),
                  _missionItem(false, "미션1 ",["내용1","내용2"]),
                  _missionItem(true, "미션2 ",["내용1","내용2"]),
                  _missionItem(true, "미션3",["내용1","내용2",""]),
                ],
              ),
            ]
        ),
      ),
    );
  }
}

Widget _missionItem(bool isCompleted, String mission, List<String> tasks) {  //미션이랑 미션 내용 나타내는거 위젯으로 그냥 해 놓음
  return Card(
    child: Padding(padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.cancel,
                color: isCompleted ? Color(0xFF008000) : Color(0xFFFF0000),
              ),
              SizedBox(width: 7,),
              Text(mission,
                style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: tasks
                .map((task) => Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 4),
              child: Text("• $task", style: TextStyle(fontSize: 15)),
            ))
                .toList(),
          )
        ],
      ),
    ),
  );
}