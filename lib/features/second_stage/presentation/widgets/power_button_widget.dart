import 'dart:async';

import 'package:flutter/material.dart';

class PowerButtonWidget extends StatefulWidget {
  const PowerButtonWidget({
    super.key,
    required this.onPowerDepleted,
    required this.onAlarmChanged,
    this.isPowerDepleted = false,
  });

  final VoidCallback onPowerDepleted;

  final ValueChanged<bool> onAlarmChanged;

  /// يحدد هل الطاقة وصلت للصفر في المحاولة الحالية.
  final bool isPowerDepleted;

  @override
  State<PowerButtonWidget> createState() =>
      _PowerButtonWidgetState();
}

class _PowerButtonWidgetState extends State<PowerButtonWidget> {
  Timer? _drainTimer;

  Timer? _chargingTimer;

  int _power = 100;

  bool _isCharging = false;

  bool _isDepleted = false;

  bool _hasNotifiedDepletion = false;

  static const int _initialPower = 100;

  static const int _drainAmount = 2;

  static const Duration _drainInterval =
      Duration(seconds: 2);

  static const Duration _chargingInterval =
      Duration(seconds: 1);

  @override
  void initState() {
    super.initState();

    _isDepleted = widget.isPowerDepleted;

    _power = _isDepleted ? 0 : _initialPower;

    if (!_isDepleted) {
      _startDrainTimer();
    }
  }

  @override
  void didUpdateWidget(covariant PowerButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isPowerDepleted &&
        widget.isPowerDepleted) {
      _stopDrainTimer();

      _stopChargingTimer();

      _isCharging = false;

      _isDepleted = true;

      _power = 0;

      _notifyAlarm(false);

      _hasNotifiedDepletion = true;
    }

    if (oldWidget.isPowerDepleted &&
        !widget.isPowerDepleted) {
      _resetForNewAttempt();
    }
  }

  void _startDrainTimer() {
    _drainTimer?.cancel();

    if (_isDepleted || _isCharging || !mounted) {
      return;
    }

    _drainTimer = Timer.periodic(
      _drainInterval,
      (timer) {
        if (!mounted || _isDepleted || _isCharging) {
          timer.cancel();
          return;
        }

        setState(() {
          _power = (_power - _drainAmount).clamp(0, 100);
        });

        _updateAlarm();

        if (_power == 0) {
          _depletePower();
        }
      },
    );
  }

  void _startChargingTimer() {
    _chargingTimer?.cancel();

    _chargingTimer = Timer.periodic(
      _chargingInterval,
      (timer) {
        if (!mounted || !_isCharging || _isDepleted) {
          timer.cancel();
          return;
        }

        if (_power >= 100) {
          setState(() {
            _power = 100;
          });

          _stopChargingTimer();

          _isCharging = false;

          _startDrainTimer();

          _updateAlarm();

          return;
        }

        setState(() {
          _power = (_power + 1).clamp(0, 100);
        });

        _updateAlarm();
      },
    );
  }

  void _stopDrainTimer() {
    _drainTimer?.cancel();

    _drainTimer = null;
  }

  void _stopChargingTimer() {
    _chargingTimer?.cancel();

    _chargingTimer = null;
  }

  void _updateAlarm() {
    if (_isDepleted || _power == 0) {
      _notifyAlarm(false);
      return;
    }

    _notifyAlarm(_power <= 20);
  }

  void _notifyAlarm(bool shouldPlay) {
    widget.onAlarmChanged(shouldPlay);
  }

  void _depletePower() {
    if (_isDepleted) {
      return;
    }

    _stopDrainTimer();

    _stopChargingTimer();

    _isCharging = false;

    _isDepleted = true;

    _power = 0;

    _notifyAlarm(false);

    if (mounted) {
      setState(() {});
    }

    if (!_hasNotifiedDepletion) {
      _hasNotifiedDepletion = true;

      widget.onPowerDepleted();
    }
  }

  void _startCharging() {
    if (_isDepleted || widget.isPowerDepleted) {
      return;
    }

    if (_isCharging) {
      return;
    }

    _isCharging = true;

    _stopDrainTimer();

    _startChargingTimer();

    if (mounted) {
      setState(() {});
    }
  }

  void _stopCharging() {
    if (!_isCharging) {
      return;
    }

    _isCharging = false;

    _stopChargingTimer();

    if (!_isDepleted) {
      _startDrainTimer();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _resetForNewAttempt() {
    _stopDrainTimer();

    _stopChargingTimer();

    _isCharging = false;

    _isDepleted = false;

    _hasNotifiedDepletion = false;

    _power = _initialPower;

    _notifyAlarm(false);

    if (mounted) {
      setState(() {});
    }

    _startDrainTimer();
  }

  Color _getPowerColor() {
    if (_power <= 20) {
      return Colors.red;
    }

    if (_power <= 50) {
      return Colors.orange;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isUnavailable =
        _isDepleted || widget.isPowerDepleted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 94,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.battery_charging_full,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _power / 100,
                  minHeight: 9,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPowerColor(),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$_power%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTapDown: isUnavailable
              ? null
              : (_) => _startCharging(),
          onTapUp: isUnavailable
              ? null
              : (_) => _stopCharging(),
          onTapCancel: isUnavailable
              ? null
              : _stopCharging,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isUnavailable
                  ? Colors.grey.shade900
                  : _isCharging
                      ? Colors.green.shade900
                      : Colors.black.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnavailable
                    ? Colors.grey
                    : _isCharging
                        ? Colors.greenAccent
                        : Colors.white70,
                width: 2,
              ),
              boxShadow: _isCharging
                  ? [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _isCharging
                  ? Icons.battery_charging_full
                  : Icons.power_settings_new,
              color: isUnavailable
                  ? Colors.grey
                  : Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          isUnavailable
              ? 'NO POWER'
              : _isCharging
                  ? 'CHARGING'
                  : 'HOLD TO CHARGE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isUnavailable
                ? Colors.redAccent
                : Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _stopDrainTimer();

    _stopChargingTimer();

    super.dispose();
  }
}

// import 'dart:async';

// import 'package:flutter/material.dart';

// class PowerButtonWidget extends StatefulWidget {
//   final VoidCallback onPowerDepleted;
//   final ValueChanged<bool> onAlarmChanged;

//   const PowerButtonWidget({
//     super.key,
//     required this.onPowerDepleted,
//     required this.onAlarmChanged,
//   });

//   @override
//   State<PowerButtonWidget> createState() =>
//       _PowerButtonWidgetState();
// }

// class _PowerButtonWidgetState
//     extends State<PowerButtonWidget> {
//   int power = 100;

//   Timer? _drainTimer;
//   Timer? _chargeTimer;

//   bool isCharging = false;
//   bool _isDepleted = false;
//   bool _isAlarmActive = false;

//   @override
//   void initState() {
//     super.initState();

//     _startDrainingPower();
//   }

//   // =========================================================
//   // استهلاك الطاقة
//   // =========================================================

//   void _startDrainingPower() {
//     _drainTimer?.cancel();

//     if (_isDepleted || power <= 0 || isCharging) {
//       return;
//     }

//     _drainTimer = Timer.periodic(
//       const Duration(seconds: 2),
//       (timer) {
//         if (!mounted || _isDepleted || isCharging) {
//           timer.cancel();
//           return;
//         }

//         setState(() {
//           power = (power - 2).clamp(0, 100);
//         });

//         _updateAlarm();

//         if (power == 0) {
//           _depletePower();
//         }
//       },
//     );
//   }

//   // =========================================================
//   // شحن الطاقة
//   // =========================================================

//   void _startCharging() {
//     if (_isDepleted || isCharging || power >= 100) {
//       return;
//     }

//     setState(() {
//       isCharging = true;
//     });

//     _drainTimer?.cancel();

//     _chargeTimer = Timer.periodic(
//       const Duration(seconds: 1),
//       (timer) {
//         if (!mounted || _isDepleted) {
//           timer.cancel();
//           return;
//         }

//         if (power >= 100) {
//           timer.cancel();
//           _chargeTimer = null;
//           return;
//         }

//         setState(() {
//           power = (power + 1).clamp(0, 100);
//         });

//         _updateAlarm();

//         if (power >= 100) {
//           timer.cancel();
//           _chargeTimer = null;
//         }
//       },
//     );
//   }

//   void _stopCharging() {
//     if (!isCharging) return;

//     _chargeTimer?.cancel();
//     _chargeTimer = null;

//     setState(() {
//       isCharging = false;
//     });

//     if (!_isDepleted) {
//       _startDrainingPower();
//     }
//   }

//   // =========================================================
//   // إنذار انخفاض الطاقة
//   // =========================================================

//   void _updateAlarm() {
//     final shouldAlarm =
//         power <= 10 && !_isDepleted;

//     if (shouldAlarm == _isAlarmActive) {
//       return;
//     }

//     _isAlarmActive = shouldAlarm;

//     widget.onAlarmChanged(shouldAlarm);
//   }

//   // =========================================================
//   // انتهاء الطاقة
//   // =========================================================

//   void _depletePower() {
//     if (_isDepleted) return;

//     _isDepleted = true;

//     _drainTimer?.cancel();
//     _chargeTimer?.cancel();

//     _drainTimer = null;
//     _chargeTimer = null;

//     _isAlarmActive = false;

//     widget.onAlarmChanged(false);

//     setState(() {
//       power = 0;
//       isCharging = false;
//     });

//     widget.onPowerDepleted();
//   }

//   // =========================================================
//   // تنظيف الموارد
//   // =========================================================

//   @override
//   void dispose() {
//     _drainTimer?.cancel();
//     _chargeTimer?.cancel();

//     if (_isAlarmActive) {
//       widget.onAlarmChanged(false);
//       _isAlarmActive = false;
//     }

//     super.dispose();
//   }

//   // =========================================================
//   // واجهة الطاقة
//   // =========================================================

//   @override
//   Widget build(BuildContext context) {
//     final isLowPower = power <= 10;

//     final powerColor = isLowPower
//         ? Colors.red
//         : Colors.greenAccent;

//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GestureDetector(
//           onTapDown: (_) => _startCharging(),
//           onTapUp: (_) => _stopCharging(),
//           onTapCancel: _stopCharging,
//           child: Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.black.withValues(alpha: 0.8),
//               border: Border.all(
//                 color: isCharging
//                     ? Colors.greenAccent
//                     : powerColor,
//                 width: 2,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               Icons.bolt,
//               color: isCharging
//                   ? Colors.greenAccent
//                   : powerColor,
//               size: 32,
//             ),
//           ),
//         ),

//         const SizedBox(width: 10),

//         Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '$power%',
//               style: TextStyle(
//                 color: powerColor,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 5),

//             SizedBox(
//               width: 85,
//               child: LinearProgressIndicator(
//                 value: power / 100,
//                 minHeight: 6,
//                 backgroundColor: Colors.white24,
//                 valueColor:
//                     AlwaysStoppedAnimation<Color>(
//                   powerColor,
//                 ),
//               ),
//             ),

//             if (isCharging) ...[
//               const SizedBox(height: 5),

//               const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(
//                     width: 12,
//                     height: 12,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.greenAccent,
//                     ),
//                   ),

//                   SizedBox(width: 5),

//                   Text(
//                     'Charging...',
//                     style: TextStyle(
//                       color: Colors.greenAccent,
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ),
//             ],

//             if (isLowPower) ...[
//               const SizedBox(height: 5),

//               const Text(
//                 'LOW POWER!',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ],
//     );
//   }
// }

// // import 'dart:async';

// // import 'package:flutter/material.dart';

// // class PowerButtonWidget extends StatefulWidget {
// // final VoidCallback onPowerDepleted;
// // final ValueChanged<bool> onAlarmChanged;

// // const PowerButtonWidget({
// // super.key,
// // required this.onPowerDepleted,
// // required this.onAlarmChanged,
// // });

// // @override
// // State<PowerButtonWidget> createState() => _PowerButtonWidgetState();
// // }

// // class _PowerButtonWidgetState extends State<PowerButtonWidget> {
// // int power = 100;

// // Timer? _drainTimer;
// // Timer? _chargeTimer;

// // bool isCharging = false;
// // bool _isDepleted = false;
// // bool _isAlarmActive = false;

// // @override
// // void initState() {
// // super.initState();
// // _startDrainingPower();
// // }

// // void _startDrainingPower() {
// // _drainTimer?.cancel();


// // if (_isDepleted || power <= 0 || isCharging) return;

// // _drainTimer = Timer.periodic(
// //   const Duration(seconds: 2),
// //   (timer) {
// //     if (!mounted || _isDepleted || isCharging) {
// //       timer.cancel();
// //       return;
// //     }

// //     setState(() {
// //       power = (power - 2).clamp(0, 100);
// //     });

// //     _updateAlarm();

// //     if (power == 0) {
// //       _depletePower();
// //     }
// //   },
// // );


// // }

// // void _startCharging() {
// // if (_isDepleted || isCharging || power >= 100) return;


// // setState(() {
// //   isCharging = true;
// // });

// // _drainTimer?.cancel();

// // _chargeTimer = Timer.periodic(
// //   const Duration(seconds: 1),
// //   (timer) {
// //     if (!mounted || _isDepleted) {
// //       timer.cancel();
// //       return;
// //     }

// //     if (power >= 100) {
// //       timer.cancel();
// //       _chargeTimer = null;
// //       return;
// //     }

// //     setState(() {
// //       power = (power + 1).clamp(0, 100);
// //     });

// //     _updateAlarm();

// //     if (power >= 100) {
// //       timer.cancel();
// //       _chargeTimer = null;
// //     }
// //   },
// // );


// // }

// // void _stopCharging() {
// // if (!isCharging) return;


// // _chargeTimer?.cancel();
// // _chargeTimer = null;

// // setState(() {
// //   isCharging = false;
// // });

// // if (!_isDepleted) {
// //   _startDrainingPower();
// // }


// // }

// // void _updateAlarm() {
// // final shouldAlarm = power <= 10 && !_isDepleted;


// // if (shouldAlarm == _isAlarmActive) return;

// // _isAlarmActive = shouldAlarm;
// // widget.onAlarmChanged(shouldAlarm);


// // }

// // void _depletePower() {
// // if (_isDepleted) return;


// // _isDepleted = true;
// // _drainTimer?.cancel();
// // _chargeTimer?.cancel();
// // _drainTimer = null;
// // _chargeTimer = null;

// // _isAlarmActive = false;
// // widget.onAlarmChanged(false);

// // setState(() {
// //   power = 0;
// //   isCharging = false;
// // });

// // widget.onPowerDepleted();


// // }

// // @override
// // void dispose() {
// // _drainTimer?.cancel();
// // _chargeTimer?.cancel();


// // if (_isAlarmActive) {
// //   widget.onAlarmChanged(false);
// // }

// // super.dispose();


// // }

// // @override
// // Widget build(BuildContext context) {
// // final isLowPower = power <= 10;
// // final powerColor = isLowPower ? Colors.red : Colors.greenAccent;

// // return Row(
// //   mainAxisSize: MainAxisSize.min,
// //   children: [
// //     GestureDetector(
// //       onTapDown: (_) => _startCharging(),
// //       onTapUp: (_) => _stopCharging(),
// //       onTapCancel: _stopCharging,
// //       child: Container(
// //         width: 50,
// //         height: 50,
// //         decoration: BoxDecoration(
// //           color: Colors.black.withValues(alpha: 0.8),
// //           border: Border.all(
// //             color: isCharging ? Colors.greenAccent : powerColor,
// //             width: 2,
// //           ),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         child: Icon(
// //           Icons.bolt,
// //           color: isCharging ? Colors.greenAccent : powerColor,
// //           size: 32,
// //         ),
// //       ),
// //     ),
// //     const SizedBox(width: 10),
// //     Column(
// //       mainAxisSize: MainAxisSize.min,
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           '$power%',
// //           style: TextStyle(
// //             color: powerColor,
// //             fontSize: 18,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         const SizedBox(height: 5),
// //         SizedBox(
// //           width: 85,
// //           child: LinearProgressIndicator(
// //             value: power / 100,
// //             minHeight: 6,
// //             backgroundColor: Colors.white24,
// //             valueColor: AlwaysStoppedAnimation<Color>(powerColor),
// //           ),
// //         ),
// //         if (isCharging) ...[
// //           const SizedBox(height: 5),
// //           const Row(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               SizedBox(
// //                 width: 12,
// //                 height: 12,
// //                 child: CircularProgressIndicator(
// //                   strokeWidth: 2,
// //                   color: Colors.greenAccent,
// //                 ),
// //               ),
// //               SizedBox(width: 5),
// //               Text(
// //                 'Charging...',
// //                 style: TextStyle(
// //                   color: Colors.greenAccent,
// //                   fontSize: 10,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //         if (isLowPower) ...[
// //           const SizedBox(height: 5),
// //           const Text(
// //             'LOW POWER!',
// //             style: TextStyle(
// //               color: Colors.red,
// //               fontSize: 10,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ],
// //     ),
// //   ],
// // );


// // }
// // }

