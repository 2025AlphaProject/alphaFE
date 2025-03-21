import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'add_page_3.dart';
import '../../components/app_bar.dart';

class AddPage_2 extends StatelessWidget {
  final String title;
  final String place;

  const AddPage_2({
    required this.title,
    required this.place,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "추가페이지_2nd"),
      body: Stack(
        //alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                minWidth: MediaQuery.of(context).size.width
              ),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$title, $place", style: TextStyle(fontSize: 20)),
                ]
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => AddPage_3()
                    )
                );
              },
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(250, 45),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                  backgroundColor: Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  )
              ),
              child: Center(
                child: Text(
                  "이 코스로 할게요!",
                  style: TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          )
        ]
      ),
    );
  }
}
