
import 'package:flutter/material.dart';
import 'package:the_void/features/second_stage/presentation/widgets/blinking_cursor.dart';

class ComputerScreen extends StatefulWidget {
  final VoidCallback onCorrectPassword;

  const ComputerScreen({
    super.key,
    required this.onCorrectPassword,
  });

  @override
  State<ComputerScreen> createState() => _ComputerScreenState();
}

class _ComputerScreenState extends State<ComputerScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    // التركيز تلقائيًا عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitPassword() {
    final input = _controller.text.trim();

    if (input == 'DIVAD') {
      widget.onCorrectPassword();
    } else {
      setState(() {
        errorMessage = 'Wrong Password! Try Again.';
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        // تحديد عرض مناسب لمحتوى شاشة الكمبيوتر
        final contentWidth = (width * 0.65).clamp(
          0.0,
          650.0,
        );
        // أحجام الخطوط مع حدود دنيا وعليا
        final titleFontSize = (width * 0.022).clamp(
          14.0,
          24.0,
        );

        final passwordFontSize = (width * 0.025).clamp(
          16.0,
          28.0,
        );

        final errorFontSize = (width * 0.018).clamp(
          12.0,
          18.0,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.85),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: height * 0.05,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان إدخال كلمة المرور
                      Text(
                        'ENTER PASSWORD:',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),

                      SizedBox(height: height * 0.035),

                      // حقل إدخال كلمة المرور
                      Stack(
                        children: [
                          Opacity(
                            opacity: 0,
                            child: SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                onSubmitted: (_) => _submitPassword(),
                                onChanged: (_) {
                                  setState(() {
                                    errorMessage = '';
                                  });
                                },
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.008,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    _controller.text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: passwordFontSize,
                                      fontFamily: 'monospace',
                                      letterSpacing: width * 0.002,
                                    ),
                                  ),
                                ),

                                SizedBox(width: width * 0.005),

                                BlinkingCursor(
                                  cursorWidth: (width * 0.008).clamp(
                                    5.0,
                                    10.0,
                                  ),
                                  cursorHeight: (height * 0.045).clamp(
                                    16.0,
                                    28.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.015),

                      // رسالة الخطأ
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: errorFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      SizedBox(height: height * 0.035),

                      // زر التحقق من كلمة المرور
                      SizedBox(
                        width: double.infinity,
                        child:GestureDetector(
                          onTap: _submitPassword,
                          child: Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: errorFontSize,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}