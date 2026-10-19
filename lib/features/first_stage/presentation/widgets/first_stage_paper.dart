
import 'package:flutter/material.dart';
import 'package:the_void/core/utlis/assets_image.dart';

class FirstStagePaper extends StatelessWidget {
  const FirstStagePaper({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.black.withOpacity(0.75),
      child: Stack(
        children: [
          // الضغط خارج الورقة يقفلها.
          // Positioned.fill(
          //   child: GestureDetector(
          //     behavior: HitTestBehavior.opaque,
          //     onTap: onClose,
          //   ),
          // ),

          // صورة الورقة في منتصف الشاشة.
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width * 0.8,
                  maxHeight: screenSize.height * 0.85,
                ),
                child: Image.asset(
                  AssetsImage.firstStagePaperImage,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // زر الإغلاق.
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: onClose,
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

