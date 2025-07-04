import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const DefaultAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      // AppBar에 그림자 효과 추가
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          )
        ],
      ),
      height: height * 0.147,
      child: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
    );
  }

  // AppBar 높이 설정 (kToolbarHeight = 기본 높이)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}