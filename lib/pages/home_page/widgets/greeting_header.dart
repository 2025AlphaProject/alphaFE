import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String? username;

  const GreetingHeader({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              username ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            const Text(
              '님',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const Text(
          "오늘도 좋은 하루에요 👋",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
      ],
    );
  }
}