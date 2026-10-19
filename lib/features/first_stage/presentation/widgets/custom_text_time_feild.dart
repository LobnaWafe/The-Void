
import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomTextTimeFeild extends StatelessWidget {
  const CustomTextTimeFeild({
    super.key,
    required this.screenSize,
    required this.timeController,
    this.updateClockHands,
    this.checkAnswer,
  });

  final Size screenSize;
  final TextEditingController timeController;
  final void Function(String)? updateClockHands;
  final void Function(String)? checkAnswer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: math.min(screenSize.width * 0.6, 320.0),
      child: TextField(
        controller: timeController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.datetime,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
        ),
        decoration: InputDecoration(
         // labelText: 'اضبط الوقت',
          hintText: '03:15',
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
        onChanged: updateClockHands,
        onSubmitted: (value) => checkAnswer?.call(value),
      ),
    );
  }
}