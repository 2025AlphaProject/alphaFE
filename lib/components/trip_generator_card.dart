// 추가 페이지에서 사용되는 행정구역 선택 버튼 아이템입니다
// 해당 버튼은 항상 AddPage_2 로 연결됩니다
import 'dart:ui';
import 'package:alpha_fe/components/auth_token_handler.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFD9D9D9), width: screenWidth * 0.0035),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        //color: const Color(0xFFF5F5F5),
      ),
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AddPage_2(
                  title: title,
                  tourId: tourId,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF5F5F5),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.05,
                horizontal: screenWidth * 0.04
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    color: Color(0xFF000000)
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Color(0xFF000000),
                size: screenWidth * 0.04,
              )
            ],
          )
      ),
    );
  }
}

