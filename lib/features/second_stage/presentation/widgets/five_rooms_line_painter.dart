
import 'package:flutter/material.dart';

class FiveRoomsLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.6)
      ..strokeWidth = size.width * 0.012
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width * 0.51;
    final centerY = size.height * 0.48;

    final path = Path()
      // Room 1 → Room 3
      ..moveTo(centerX, size.height * 0.20)
      ..lineTo(centerX, size.height * 0.39)
      // Room 2 → Room 3
      ..moveTo(size.width * 0.22, centerY)
      ..lineTo(size.width * 0.36, centerY)
      // Room 4 → Room 3
      ..moveTo(size.width * 0.66, centerY)
      ..lineTo(size.width * 0.82, centerY)
      // Room 3 → Room 5
      ..moveTo(centerX, size.height * 0.60)
      ..lineTo(centerX, size.height * 0.83);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FiveRoomsLinesPainter oldDelegate) {
    return false;
  }
}
