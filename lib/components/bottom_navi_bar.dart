import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30.0),
              topLeft: Radius.circular(30.0)
          ),
          boxShadow: [
            BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, -2)
            )
          ],
        ),
        height: 60,
        child: ClipRRect(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.0),
                topLeft: Radius.circular(30.0)
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Color(0xFFFFFFFF),
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(color: Colors.black),
              unselectedLabelStyle: const TextStyle(color: Colors.grey),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: '홈'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.map_outlined),
                    label: '계획'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline),
                    label: '추가'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: '마이'
                ),
              ],
            )
        )
    );
  }
}
