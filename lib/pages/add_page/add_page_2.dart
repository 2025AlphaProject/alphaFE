import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'add_page_3.dart';
import '../../components/app_bar.dart';
import '../../components/proceed_button.dart';
import '../../components/placeinfo_card.dart';

class AddPage_2 extends StatelessWidget {
  final String title;

  const AddPage_2({
    required this.title,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "추가페이지_2nd"),

      body: Stack(
        // "이 코스로 할게요!" 버튼이 다른 UI 요소 위에 그려지도록 하기 위해 Stack 사용
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
              child: ConstrainedBox(
                // Stack + ScrollView 조합 시, 자식 요소가 화면을 벗어나 배치되는 문제 방지를 위해 사용
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height, // 최소 높이를 화면 크기로 제한
                    minWidth: MediaQuery.of(context).size.width
                ),

                // 코스 정보를 담은 UI 블록들을 수직으로 배치
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // 이 곳에 위젯들 배치
                  children: [
                    SizedBox(height: 26,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "📍$title",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(
                                '근처 코스를 알려드릴게요',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF757575)
                                ),
                              )
                            ]
                        ),
                        SizedBox(height: 8,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '최근 업데이트',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xFF7F7F7F)
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(
                              '2025.00.00',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                  color: Color(0xFF7F7F7F)
                              ),
                            ),
                          ],
                        )
                      ]
                    ),
                    SizedBox(height: 24,),
                    PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/여의도_한강공원.jpg/1280px-여의도_한강공원.jpg',
                        title: '한강공원',
                        description: '설명 영역입니다 ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ'
                    ),
                    SizedBox(height: 24,),
                    PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/ba/Seoul_Tower_%284394893276%29.jpg',
                        title: 'N서울타워',
                        description: '설명 영역입니다 ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ'
                    ),
                    SizedBox(height: 24,),
                    PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Bukchon_Hanok_Village_북촌_한옥마을_October_1_2020_15.jpg/1920px-Bukchon_Hanok_Village_북촌_한옥마을_October_1_2020_15.jpg',
                        title: '북촌 한옥마을',
                        description: '설명 영역입니다 ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ'
                    )
                  ],
                ),
              ),
            ),
          ),

          // "이 코스로 할게요!" 버튼을 화면 하단에 고정 배치
          Positioned(
            bottom: 30,
            child: ProceedButton(
              size_w: 200,
              size_h: 45,
              text: "이 코스로 할게요!",
              fontSize_: 15,
              fontWeight_: FontWeight.bold,
              padding_: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => AddPage_3(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}