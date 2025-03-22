import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const DefaultAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // AppBar에 그림자 효과 추가
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      height: 120,
      child: AppBar(
        title: Text(title),
        backgroundColor: Color(0xFFFFFFFF),
      ),
    );
  }

  // AppBar 높이 설정 (kToolbarHeight = 기본 높이)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}