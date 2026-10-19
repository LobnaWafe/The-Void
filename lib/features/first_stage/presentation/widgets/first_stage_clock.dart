import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:the_void/core/utlis/assets_image.dart';
import 'package:the_void/features/first_stage/presentation/widgets/clock_hands_pointer.dart';
import 'package:the_void/features/first_stage/presentation/widgets/custom_text_time_feild.dart';

class FirstStageClock extends StatefulWidget {
  const FirstStageClock({
    super.key,
    required this.onClose,
    required this.onSolved,
  });

  final VoidCallback onClose;
  final VoidCallback onSolved;

  @override
  State<FirstStageClock> createState() => _FirstStageClockState();
}

class _FirstStageClockState extends State<FirstStageClock> {
  final TextEditingController _timeController =
      TextEditingController(text: '03:15');

  int _hour = 3;
  int _minute = 15;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _updateClockHands('03:15');
  }

  void _updateClockHands(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value);

    if (match == null) return;

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
      return;
    }

    setState(() {
      _hour = hour;
      _minute = minute;
      _errorMessage = null;
    });
  }

  void _checkAnswer() {
    final value = _timeController.text.trim();

    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value);

    if (match == null) {
      setState(() {
        _errorMessage = "write clock right , like 03:15";
      });
      return;
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
      setState(() {
        _errorMessage = "wrong time , try again";
      });
      return;
    }

    if (hour == 10 && minute == 50) {
      widget.onSolved();
      return;
    }

    setState(() {
      _errorMessage = "wrong time , try again";
    });
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final clockSize = math.min(
      screenSize.width * 0.42,
      screenSize.height * 0.55,
    );

    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          // إغلاق الساعة عند الضغط خارجها.
          // Positioned.fill(
          //   child: GestureDetector(
          //     behavior: HitTestBehavior.opaque,
          //     onTap: widget.onClose,
          //   ),
          // ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // وجه الساعة والعقارب مرسومة بالـ CustomPainter.
                  SizedBox(
                    width: clockSize,
                    height: clockSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // وجه الساعة
                        Positioned.fill(
                          child: Image.asset(
                            AssetsImage.clockImage,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // رسم العقارب وعقارب الساعة عبر CustomPainter
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ClockHandsPainter(
                              hour: _hour,
                              minute: _minute,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  CustomTextTimeFeild(
                    screenSize: screenSize,
                    timeController: _timeController,
                    checkAnswer: (_) {
                      _checkAnswer();
                    },
                    updateClockHands: _updateClockHands,
                  ),

                  const SizedBox(height: 12),

                  if (_errorMessage != null)
                    ErrorMessageWidget(errorMessage: _errorMessage),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    
                    onPressed: _checkAnswer,
                    child: const Text("check",style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ],
              ),
            ),
          ),

          // زر الإغلاق.
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: widget.onClose,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorMessageWidget extends StatelessWidget {
  const ErrorMessageWidget({
    super.key,
    required String? errorMessage,
  }) : _errorMessage = errorMessage;

  final String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Text(
        _errorMessage!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 16,
        ),
      ),
    );
  }
}
