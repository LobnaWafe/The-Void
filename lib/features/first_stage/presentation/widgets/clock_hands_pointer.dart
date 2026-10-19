
// CustomPainter لرسم العقارب بدقة متناهية من المركز
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ClockHandsPainter extends CustomPainter {
  final int hour;
  final int minute;

  ClockHandsPainter({required this.hour, required this.minute});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // حساب زاوية عقرب الساعات (تتحرك بمرور الدقائق أيضاً)
    final hourFraction = ((hour % 12) + minute / 60.0) / 12.0;
    final hourAngle = hourFraction * 2 * math.pi - math.pi / 2;

    // حساب زاوية عقرب الدقائق
    final minuteFraction = minute / 60.0;
    final minuteAngle = minuteFraction * 2 * math.pi - math.pi / 2;

    // رسم عقرب الساعات
    final hourPaint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final hourHandLength = radius * 0.5;
    final hourEnd = Offset(
      center.dx + hourHandLength * math.cos(hourAngle),
      center.dy + hourHandLength * math.sin(hourAngle),
    );
    canvas.drawLine(center, hourEnd, hourPaint);

    // رسم عقرب الدقائق
    final minutePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = radius * 0.05
      ..strokeCap = StrokeCap.round;

    final minuteHandLength = radius * 0.7;
    final minuteEnd = Offset(
      center.dx + minuteHandLength * math.cos(minuteAngle),
      center.dy + minuteHandLength * math.sin(minuteAngle),
    );
    canvas.drawLine(center, minuteEnd, minutePaint);

    // رسم نقطة مركز الساعة في المنتصف تماماً
    final pinPaint = Paint()..color = const Color(0xFF8B8065);
    canvas.drawCircle(center, radius * 0.04, pinPaint);
  }

  @override
  bool shouldRepaint(covariant ClockHandsPainter oldDelegate) {
    return oldDelegate.hour != hour || oldDelegate.minute != minute;
  }
}
