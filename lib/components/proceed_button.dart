import 'package:flutter/material.dart';

class ProceedButton extends StatelessWidget {
  final double size_w; // 버튼 너비
  final double size_h; // 버튼 높이
  final String text; // 버튼 텍스트
  final FontWeight fontWeight_; // 버튼 텍스트 굵기
  final double fontSize_; // 버튼 텍스트 크기
  final Function()? onTap; // 탭할 시 실행될 함수

  const ProceedButton ({
    Key? key,
    required this.size_w,
    required this.size_h,
    required this.text,
    required this.fontSize_,
    required this.fontWeight_,
    this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(

        // WidgetStateProperty.all -> hover, tap 등 모든 동작 상황에 같은 스타일 적용
        backgroundColor: MaterialStateProperty.all(const Color(0xFF2C2C2C)),
        foregroundColor: MaterialStateProperty.all(const Color(0xFFF5F5F5)),
        fixedSize: MaterialStateProperty.all(Size(size_w, size_h)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: fontSize_,
            fontWeight: fontWeight_,
          ),
        ),
      ),
      child: Text(text),
    );
  }
}