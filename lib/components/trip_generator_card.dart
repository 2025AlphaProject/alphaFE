// 추가 페이지에서 사용되는 행정구역 선택 버튼 아이템입니다
// 해당 버튼은 항상 AddPage_2 로 연결됩니다
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../pages/add_page/add_page_2.dart';

class GeneratorItem extends StatelessWidget {
  final String title;
  final int tourId;

  const GeneratorItem({
    required this.title,
    required this.tourId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFD9D9D9), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        //color: const Color(0xFFF5F5F5),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AddPage_2(title: title, tourId: tourId,),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF5F5F5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF000000)
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Color(0xFF000000),
              size: 16,
            )
          ],
        )
      ),
    );
  }
}
