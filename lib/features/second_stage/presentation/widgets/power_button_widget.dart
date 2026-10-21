import 'dart:async';

import 'package:flutter/material.dart';

class PowerButtonWidget extends StatefulWidget {
  const PowerButtonWidget({super.key});

  @override
  State<PowerButtonWidget> createState() => _PowerButtonWidgetState();
}

class _PowerButtonWidgetState extends State<PowerButtonWidget> {
  int power = 100;

  Timer? _drainTimer;
  Timer? _chargeTimer;

  bool isCharging = false;

  @override
  void initState() {
    super.initState();
    _startDrainingPower();
  }

  // الطاقة تقل 1% كل 5 ثوانٍ.
  void _startDrainingPower() {
    _drainTimer?.cancel();

    if (power <= 0) return;

    _drainTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (power <= 0) {
          timer.cancel();
          return;
        }

        setState(() {
          power = (power - 1).clamp(0, 100);
        });

        if (power == 0) {
          timer.cancel();
        }
      },
    );
  }

  // بداية الضغط المستمر على زرار الطاقة.
  void _startCharging() {
    if (isCharging || power >= 100) return;

    setState(() {
      isCharging = true;
    });

    // نوقف استهلاك الطاقة أثناء الشحن.
    _drainTimer?.cancel();

    // أول زيادة بعد ثانيتين، وبعدها كل ثانيتين.
    _chargeTimer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (power >= 100) {
          timer.cancel();
          return;
        }

        setState(() {
          power = (power + 1).clamp(0, 100);
        });

        if (power >= 100) {
          timer.cancel();
        }
      },
    );
  }

  // رفع الإصبع عن الزرار.
  void _stopCharging() {
    if (!isCharging) return;

    _chargeTimer?.cancel();
    _chargeTimer = null;

    setState(() {
      isCharging = false;
    });

    // نرجع استهلاك الطاقة.
    _startDrainingPower();
  }

  @override
  void dispose() {
    _drainTimer?.cancel();
    _chargeTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زرار الطاقة.
        GestureDetector(
          onTapDown: (_) => _startCharging(),
          onTapUp: (_) => _stopCharging(),
          onTapCancel: _stopCharging,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              border: Border.all(
                color: isCharging ? Colors.greenAccent : Colors.white54,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.bolt,
              color: isCharging ? Colors.greenAccent : Colors.white,
              size: 32,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // معلومات الطاقة والشحن.
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$power%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            SizedBox(
              width: 85,
              child: LinearProgressIndicator(
                value: power / 100,
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  power <= 20 ? Colors.red : Colors.greenAccent,
                ),
              ),
            ),

            if (isCharging) ...[
              const SizedBox(height: 5),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.greenAccent,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Charging...',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}