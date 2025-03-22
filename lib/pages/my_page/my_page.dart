import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'mission_page.dart';
import 'my_page_Q&A.dart';


class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "마이 앱바 영역"),
      body: MyPageBody(),
    );
  }
}

class MyPageBody extends StatelessWidget { // 이 페이지만 바디 따로 해 놓음
  @override
  Widget build(BuildContext context)  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(  //프로필 나타내는거
              children: [
                SizedBox(height: 20),
                Container(                  //프로필 사진
                  width: 100, height: 100,
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/46028234?v=4'
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SizedBox(height: 0),
                Text(   //이름
                  '조시연',
                  style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize:18, fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 10,
                          color: Color(0xFFCCCCCC),
                        )
                      ]
                  ),
                ),
                Text(      //subtitle 구현
                  'Subtitle',
                  style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize:18, fontWeight: FontWeight.w300,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 10,
                          color: Color(0xFFCCCCCC),
                        )
                      ]
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row( //여행, 미션, 친구 수
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StateItem("15", "여행"),
                SizedBox(width: 33),
                _StateItem("15", "미션"),
                // SizedBox(width: 33),
                // _StateItem("15", "친구") //없앤다 해서 일단 주석처리
              ],
            ),
            SizedBox(height: 30,),
            SizedBox(    //프로필 수정 버튼 아마 안쓸것 같아서 사라질듯
                width: 300, height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => Mission_Page() //없앨 것 같아서 그냥 아무페이지나 연동해 놓음
                        )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFFFFF),
                    foregroundColor: Color(0xFF000000),
                    side: BorderSide(color: Color(0xFF000000), width: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: Text("프로필 수정",
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16, fontWeight: FontWeight.w600,
                    ),
                  ),
                )
            ),
            SizedBox(height: 5),
            // Divider(height: 1, thickness: 2,color: Color(0xFF757575),),
            SizedBox(height: 15,),
            Column(
              children: [  //미션 진행도 같이 다른 마이페이지 세부 기능으로 넘어가기 위한 버튼
                _menuItem(context, Icons.trending_up, "미션 진행도", Mission_Page()),
                _menuItem(context, Icons.help_outline_outlined, "자주 묻는 질문",MyPage_QA()),
              ],
            ),
          ]
      ),
    );
  }
}

Widget _StateItem(String value, String label) {  //여행,미션, 친구 관련
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(value,
        style: TextStyle(
          color: Color(0xFF000000),
          fontSize: 25, fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 7,),
      Text(label,
        style: TextStyle(
          color: Color(0xFF757575),
          fontSize: 12, fontWeight: FontWeight.normal,
        ),
      )
    ],
  );
}

Widget _menuItem(BuildContext context, IconData icon, String menu, Widget page) {  //각종 다른 기능을 가지고 있는 다른 페이지로 넘어가느거
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1),
    child: SizedBox(
      width: 300,
      child: TextButton(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => page
              )
          );
        },
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
          foregroundColor: Color(0xFFCCCCCC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Color(0xFF000000)),
            SizedBox(width: 8),
            Text(
              menu,
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
