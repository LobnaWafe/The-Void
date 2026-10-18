import 'dart:async';

import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration speed;
  final VoidCallback? onFinished;
  final String language;

  const TypewriterText({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 50),
    this.onFinished, required this.language,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;

  Timer? _textTimer;
  Timer? _cursorTimer;

  bool _showCursor = true;

  @override
  void initState() {
    super.initState();

    _startTypewriting();
    _startCursorBlink();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text ||
        oldWidget.speed != widget.speed) {
      _textTimer?.cancel();

      _displayedText = '';
      _currentIndex = 0;

      _startTypewriting();
    }
  }

  void _startTypewriting() {
    if (widget.text.isEmpty) {
      widget.onFinished?.call();
      return;
    }

    _textTimer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      }

      if (_currentIndex >= widget.text.length) {
        timer.cancel();
        widget.onFinished?.call();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _showCursor = !_showCursor;
        });
      },
    );
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _cursorTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: _displayedText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'PixelFont',
              height: 1.4,
            ),
          ),
          WidgetSpan(
            child: Opacity(
              opacity: _showCursor ? 1.0 : 0.0,
              child: const Text(
                ' ▌',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      textDirection: widget.language == 'ar'
    ? TextDirection.rtl
    : TextDirection.ltr,
    );
  }
}



// import 'dart:async';

// import 'package:flutter/material.dart';

// class TypewriterText extends StatefulWidget {
//   final String text;
//   final Duration speed;

//   const TypewriterText({
//     super.key,
//     required this.text,
//     this.speed = const Duration(milliseconds: 50),
//   });

//   @override
//   State<TypewriterText> createState() => _TypewriterTextState();
// }

// class _TypewriterTextState extends State<TypewriterText> {
//   String _displayedText = "";
//   int _currentIndex = 0;
//   Timer? _textTimer;
//   Timer? _cursorTimer;
//   bool _showCursor = true;

//   @override
//   void initState() {
//     super.initState();
//     _startTypewriting();
//     _startCursorBlink();
//   }

//   // طباعة الحروف حرفاً بحرف
//   void _startTypewriting() {
//     _textTimer = Timer.periodic(widget.speed, (timer) {
//       if (_currentIndex < widget.text.length) {
//         setState(() {
//           _displayedText += widget.text[_currentIndex];
//           _currentIndex++;
//         });
//       } else {
//         _textTimer?.cancel();
//       }
//     });
//   }

//   // جعل المؤشر يرمش (وميض)
//   void _startCursorBlink() {
//     _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       setState(() {
//         _showCursor = !_showCursor;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _textTimer?.cancel();
//     _cursorTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text.rich(
//       TextSpan(
//         children: [
//           TextSpan(
//             text: _displayedText,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontFamily: 'PixelFont', // يمكنكِ تغيير الخط لخط ألعاب إذا أردتِ
//               height: 1.4,
//             ),
//           ),
//           WidgetSpan(
//             child: Opacity(
//               opacity: _showCursor ? 1.0 : 0.0,
//               child: const Text(
//                 ' ▌', // رمز المؤشر
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       textDirection: TextDirection.rtl, // لضبط اتجاه النص العربي
//     );
//   }
// }