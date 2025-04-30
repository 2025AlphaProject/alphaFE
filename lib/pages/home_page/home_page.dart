import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import '../../components/plan_card.dart'; // 여행 계획 카드 컴포넌트
import '../../components/proceed_button.dart'; // 버튼 컴포넌트

class HomePage extends StatelessWidget {
  final String username;
  final String welcome_message;

  const HomePage({
    required this.username,
    required this.welcome_message,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    print(MediaQuery.of(context).size.height);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      // 상단 앱바
      appBar: const SearchAppBar(),

      // 콘텐츠 영역
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.066), // 좌우 여백 설정

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 유저 이름
              Text(
                '$username님,',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                )
              ),

              // 웰컴 메세지
              Text(
                  welcome_message,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  )
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.024,),
              Text(
                '⏰다가오는 일정',
                style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.072, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.012,),
              Center(
                child: PlanCard(
                  title: "성북구 산책",
                  startDate: "2025.03.18",
                  endDate: "2025.03.25",
                  size_h: MediaQuery.of(context).size.height*0.394,
                  size_w: MediaQuery.of(context).size.width*0.8,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.073,),
              Center(
                /*
                * size_w, size_h, fontSize_ : double
                * text : String
                * fontWeight_ : FontWeight
                * padding_ : EdgeInsetsGeometry
                * */
                child: ProceedButton(
                    size_w: MediaQuery.of(context).size.width*0.586,
                    size_h: MediaQuery.of(context).size.height*0.055,
                    text: "✨새로운 장소 탐험하기",
                    fontSize_: 15,
                    fontWeight_: FontWeight.bold,
                    padding_: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.032, horizontal: MediaQuery.of(context).size.height*0.014)
                )

                /*ElevatedButton(
                  onPressed: () {
                  },

                  // 버튼 스타일 지정 (크기, 색상, 모서리 둥글기 등)
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(220, 45),
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                    backgroundColor: Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: Center(
                    child: Text(
                      "✨새로운 장소 탐험하기",
                      style: TextStyle(
                        color: Color(0xFFF5F5F5),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),*/
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
                child: Text(
                  "오늘\n이런 곳은 어떤가요?",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width*0.0748,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // 이미지 추가 (클릭 시 해당 페이지 바로 이동)
              // 사진 받아 오는 API 아무거나 물어보기
            ],
          ),
        ),
      ),
    );
  }
}