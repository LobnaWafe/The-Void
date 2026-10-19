import 'dart:async';

import 'package:flutter/material.dart';
import 'package:the_void/core/utlis/assets_image.dart';

class FirstStageBox extends StatefulWidget {
  const FirstStageBox({
    super.key,
    required this.onClose,
    required this.onStageCompleted,
    required this.scaryImage,
  });

  final VoidCallback onClose;
  final VoidCallback onStageCompleted;
  final String scaryImage;

  @override
  State<FirstStageBox> createState() => _FirstStageBoxState();
}

class _FirstStageBoxState extends State<FirstStageBox> {
  bool isTakingPhoto = false;
  bool showFlash = false;
  double _flashOpacity = 0.0;
  bool showScaryImage = false;
  bool isCompleted = false;

  Future<void> _takePhoto() async {
    if (isTakingPhoto || isCompleted) return;

    setState(() {
      isTakingPhoto = true;
      showScaryImage = true; // نظهر الصورة المرعبة في الخلفية فوراً مع الضغط
      showFlash = true;
      _flashOpacity = 1.0; // الفلاش يبدأ غامطاً بالكامل ليغطي الصورة
    });

    // فترة قصيرة جداً لثبات الفلاش الأبيض بقوة
    await Future.delayed(const Duration(milliseconds: 60));

    if (!mounted) return;

    // بدء تلاشي الفلاش تدريجياً لتظهر من تحته الصورة المرعبة بسلاسة
    setState(() {
      _flashOpacity = 0.0;
    });

    // الانتظار حتى ينتهي وقت التلاشي (400 مللي ثانية)
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      showFlash = false; // إزالة طبقة الفلاش تماماً بعد انتهاء التلاشي
    });

    // مدة ظهور الصورة المرعبة بعد اختفاء الفلاش بالكامل.
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      isCompleted = true;
    });

    widget.onStageCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الصورة المرعبة موجودة في الخلفية منذ بداية الضغط وتتضح تدريجياً مع تلاشي الفلاش
            if (showScaryImage)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Image.asset(
                    widget.scaryImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            // واجهة الكاميرا (تختفي فور بدء التصوير وظهرور الصورة المرعبة في الخلفية)
            if (!showScaryImage)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: screenSize.width * 0.5,
                          maxHeight: screenSize.height * 0.55,
                        ),
                        child: Image.asset(
                          AssetsImage.cameraImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _takePhoto,
                    child: const Text(
                      'Take a photo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

            // الفلاش الأبيض المتلاشي فوق الصورة المرعبة
            if (showFlash)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _flashOpacity,
                  duration: const Duration(milliseconds: 400),
                  child: const ColoredBox(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
