import 'package:flutter/material.dart';
import 'package:the_void/features/second_stage/presentation/widgets/camera_security.dart';
import 'package:the_void/features/second_stage/presentation/widgets/computer_screen.dart';
import 'package:the_void/features/second_stage/presentation/widgets/power_button_widget.dart';
import 'package:the_void/features/second_stage/presentation/widgets/video_widget.dart';

class SecondStageViewBody extends StatefulWidget {
  const SecondStageViewBody({super.key});

  @override
  State<SecondStageViewBody> createState() => _SecondStageViewBodyState();
}

class _SecondStageViewBodyState extends State<SecondStageViewBody> {
  bool isCameraOpen = false;
  bool isComputerOpen = false;

  bool isPasswordCorrect = false;
  bool showFileIcon = false;
  bool isMonsterPresent = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            // خلفية المرحلة
            const VideoWidget(),
            Positioned(left: 20, bottom: 20, child: PowerButtonWidget()),
            // واجهة كاميرات المراقبة
            if (isCameraOpen)
              Positioned.fill(
                child: CameraSecurity(
                  isMonsterPresent: isMonsterPresent,
                  onRoomTap: (roomName) {
                    debugPrint('تم الضغط على: $roomName');
                  },
                ),
              ),

            // شاشة الكمبيوتر
            if (isComputerOpen)
              Positioned.fill(
                child: ComputerScreen(
                  onCorrectPassword: () {
                    setState(() {
                      isPasswordCorrect = true;
                      isComputerOpen = false;
                      showFileIcon = true;
                    });
                  },
                ),
              ),

            // المؤقت
            Positioned(
              top: height * 0.025,
              left: width * 0.5,
              child: Text(
                '02:59',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.018,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // زر الكمبيوتر
            Positioned(
              right: width * 0.035,
              bottom: height * 0.15,
              child: IconButton(
                onPressed: () {
                  // ممنوع فتح الكمبيوتر أثناء فتح الكاميرا
                  if (isCameraOpen || isPasswordCorrect) return;

                  setState(() {
                    isComputerOpen = !isComputerOpen;
                  });
                },
                icon: Icon(
                  isComputerOpen ? Icons.close : Icons.computer_sharp,
                  color: isPasswordCorrect ? Colors.grey : Colors.white,
                  size: width * 0.035,
                ),
              ),
            ),

            // زر الكاميرا
            Positioned(
              right: width * 0.035,
              bottom: height * 0.035,
              child: IconButton(
                onPressed: () {
                  // ممنوع فتح الكاميرا أثناء فتح الكمبيوتر
                  if (isComputerOpen) return;

                  setState(() {
                    isCameraOpen = !isCameraOpen;
                  });
                },
                icon: Icon(
                  isCameraOpen ? Icons.close : Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: width * 0.035,
                ),
              ),
            ),

            // الملف السري بعد إدخال كلمة المرور الصحيحة
            if (showFileIcon)
              Positioned(
                top: height * 0.025,
                left: width * 0.025,
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: Colors.amber,
                      size: width * 0.025,
                    ),
                    SizedBox(width: width * 0.005),
                    Text(
                      'Secret_File',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.015,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
