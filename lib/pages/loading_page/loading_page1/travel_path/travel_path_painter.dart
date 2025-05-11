import 'dart:ui';

import 'package:flutter/material.dart';

class TravelPathPainter extends CustomPainter {
  final List<double> progress;
  TravelPathPainter(this.progress);

  final Paint pathPaint = Paint()
    ..color = const Color(0xFFFF9500)
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    List<Offset> points = [
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.75),
      Offset(size.width * 0.4, size.height * 0.35),
      Offset(size.width * 0.7, size.height * 0.3),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      Path segment = Path()..moveTo(points[i].dx, points[i].dy);

      Offset midPoint = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );

      double offset = 50;
      if (i == 0) {
        midPoint = Offset(midPoint.dx, midPoint.dy + offset);
      } else if (i == 1 || i == 2) {
        midPoint = Offset(midPoint.dx, midPoint.dy - offset);
      } else {
        midPoint = Offset(midPoint.dx, midPoint.dy + offset);
      }

      segment.quadraticBezierTo(midPoint.dx, midPoint.dy, points[i + 1].dx, points[i + 1].dy);

      PathMetrics pathMetrics = segment.computeMetrics();
      for (PathMetric pathMetric in pathMetrics) {
        Path extractPath = pathMetric.extractPath(0, pathMetric.length * progress[i]);

        Path dashedPath = Path();
        double dashLength = 10.0;
        double gapLength = 5.0;
        double distance = 0.0;

        for (var metric in extractPath.computeMetrics()) {
          while (distance < metric.length) {
            double nextDistance = distance + dashLength;
            dashedPath.addPath(
              metric.extractPath(distance, nextDistance),
              Offset.zero,
            );
            distance = nextDistance + gapLength;
          }
        }

        canvas.drawPath(dashedPath, pathPaint);
      }
    }

    for (Offset point in points) {
      canvas.drawCircle(point, 8.0, Paint()..color = const Color(0xFFFF3B30));
    }
  }

  @override
  bool shouldRepaint(TravelPathPainter oldDelegate) => true;
}