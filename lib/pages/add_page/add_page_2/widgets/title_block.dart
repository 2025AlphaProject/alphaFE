import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TitleBlock extends StatelessWidget {
  final String title;
  const TitleBlock({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (kIsWeb) width = 430;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📍$title", style: const TextStyle(fontSize: 26.7, fontWeight: FontWeight.w900)),
        const Padding(
          padding: EdgeInsets.only(left: 37.5),
          child: Text('근처 코스를 알려드릴게요', style: TextStyle(fontSize: 14.3, color: Color(0xFF757575))),
        ),
        SizedBox(height: height * 0.0138),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('최근 업데이트: ', style: TextStyle(fontSize: 14.3, fontWeight: FontWeight.bold, color: Color(0xFF7F7F7F))),
              SizedBox(width: width * 0.01),
              Text(DateTime.now().toLocal().toString().substring(0, 10),
                  style: TextStyle(fontSize: width * 0.03, color: const Color(0xFF7F7F7F))),
            ],
          ),
        ),
      ],
    );
  }
}