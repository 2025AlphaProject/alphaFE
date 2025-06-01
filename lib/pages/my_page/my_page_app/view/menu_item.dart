import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

//미션 진행도랑 자주묻는 질문 나타내는 위젯
Widget menuItem(BuildContext context, IconData icon, String menu, Widget page, {VoidCallback? onTap}) {
  double width = MediaQuery.of(context).size.width;
  if (kIsWeb) {
    width = 430;
  }
  final height = MediaQuery.of(context).size.height;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: height * 0.0046),
    child: SizedBox(
      width: width * 0.75,
      child: TextButton(
        onPressed: onTap ?? () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
        },
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
          foregroundColor: const Color(0xFFCCCCCC),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.6, color: const Color(0xFF000000)),
            SizedBox(width: width * 0.02),
            Text(
              menu,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 20.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}