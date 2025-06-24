import 'package:flutter/material.dart';

class MissionProgressIndicator extends StatelessWidget {
  final int completed;
  final int total;

  const MissionProgressIndicator({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth * 0.5;
        return Center(
          child: SizedBox(
            height: size,
            width: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: total == 0 ? 0 : completed / total,
                  strokeWidth: size * 0.05,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
                ),
                Center(
                  child: Text(
                    '$completed/$total',
                    style: const TextStyle(
                      fontSize: 32.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}