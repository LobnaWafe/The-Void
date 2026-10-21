
// مؤشر الكتابة الذي يومض
import 'package:flutter/material.dart';

class BlinkingCursor extends StatefulWidget {
  final double cursorWidth;
  final double cursorHeight;

  const BlinkingCursor({
    super.key,
    required this.cursorWidth,
    required this.cursorHeight,
  });

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: widget.cursorWidth,
        height: widget.cursorHeight,
        color: Colors.greenAccent,
      ),
    );
  }
}

