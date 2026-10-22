import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_cubit.dart';
import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_state.dart';

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
  late final SecondStageCubit _cubit;

  bool isCameraOpen = false;
  bool isComputerOpen = false;

  bool isPasswordCorrect = false;
  bool showFileIcon = false;
  bool isPowerDepleted = false;

  @override
  void initState() {
    super.initState();

    _cubit = SecondStageCubit()..startStage();
  }

  @override
  void dispose() {
    _cubit.close();

    super.dispose();
  }

  // // استخراج رقم الغرفة من اسمها.
  // int? _getRoomNumber(String roomName) {
  //   final match = RegExp(r'\d+').firstMatch(roomName);

  //   if (match == null) return null;

  //   final roomNumber = int.tryParse(match.group(0)!);

  //   if (roomNumber == null ||
  //       roomNumber < 1 ||
  //       roomNumber > 5) {
  //     return null;
  //   }

  //   return roomNumber;
  // }

  // تشغيل الصوت.
  void _handleSoundTap() {
    final success = _cubit.activateSound();

    if (!success) {
      debugPrint('الصوت غير متاح حاليًا.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SecondStageCubit, SecondStageState>(
        listener: (context, state) {
          if (state is SecondStageSuccess) {
            debugPrint('انتهت المرحلة بنجاح.');
          }

          if (state is SecondStageFailure) {
            debugPrint('انتهت المرحلة بالخسارة.');
          }
        },
        builder: (context, state) {
          if (state is SecondStageInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SecondStageSuccess) {
            return const Center(
              child: Text(
                'Stage Completed!',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
            );
          }

          if (state is SecondStageFailure) {
            return const Center(
              child: Text(
                'Game Over!',
                style: TextStyle(color: Colors.red, fontSize: 28),
              ),
            );
          }

          final gameState = state as SecondStageInProgress;

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية غرفة الأمن.
                  const VideoWidget(),

                  // زر الطاقة.
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: PowerButtonWidget(
                      onPowerDepleted: () {
                        setState(() {
                          isPowerDepleted = true;
                          isCameraOpen = false;
                          isComputerOpen = false;
                        });
                      },
                      onAlarmChanged: (shouldPlay) {
                        // TODO: تشغيل أو إيقاف صوت إنذار انخفاض الطاقة.
                        // اربطي هنا AudioPlayer الخاص بالإنذار.
                      },
                    ),
                  ),

                  // واجهة كاميرات المراقبة.
                  if (isCameraOpen)
                    Positioned.fill(
                      child: CameraSecurity(
                        selectedRoom: gameState.selectedCameraRoom,
                        isMonsterPresent: gameState.isMonsterInSelectedRoom,
                        onRoomTap: _cubit.selectCameraRoom,
                        isSoundLoading: !gameState.canUseSound,
                        soundSecondsRemaining: gameState.soundCooldownRemaining,
                        onSoundTap: _handleSoundTap,
                      ),
                    ),

                  // شاشة الكمبيوتر.
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

                  // مؤقت المرحلة.
                  Positioned(
                    top: height * 0.025,
                    left: width * 0.5,
                    child: Text(
                      gameState.formattedTime,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.018,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // تحذير اقتراب الوحش.
                  if (gameState.monsterRoom == 5)
                    Positioned(
                      top: height * 0.08,
                      left: width * 0.5,
                      child: Column(
                        children: [
                          Text(
                            gameState.isAttackStarted
                                ? 'ATTACK!'
                                : 'FOOTSTEPS NEARBY',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: width * 0.018,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (gameState.attackSecondsRemaining > 0)
                            Text(
                              gameState.formattedAttackTime,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: width * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),

                  // زر الكمبيوتر.
                  Positioned(
                    right: width * 0.035,
                    bottom: height * 0.15,
                    child: IconButton(
                      onPressed: () {
                        if (isCameraOpen || isPasswordCorrect) {
                          return;
                        }

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

                  // زر الكاميرا.
                  Positioned(
                    right: width * 0.035,
                    bottom: height * 0.035,
                    child: IconButton(
                      onPressed: () {
                        if (isComputerOpen) return;

                        setState(() {
                          if (!isCameraOpen) {
                            _cubit.selectCameraRoom(1);
                            isCameraOpen = true;
                          } else {
                            isCameraOpen = false;
                          }
                        });
                      },
                      icon: Icon(
                        isCameraOpen ? Icons.close : Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: width * 0.035,
                      ),
                    ),
                  ),

                  // الملف السري.
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
        },
      ),
    );
  }
}

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:the_void/features/second_stage/presentation/widgets/camera_security.dart';
// import 'package:the_void/features/second_stage/presentation/widgets/computer_screen.dart';
// import 'package:the_void/features/second_stage/presentation/widgets/power_button_widget.dart';
// import 'package:the_void/features/second_stage/presentation/widgets/video_widget.dart';

// class SecondStageViewBody extends StatefulWidget {
//   const SecondStageViewBody({super.key});

//   @override
//   State<SecondStageViewBody> createState() => _SecondStageViewBodyState();
// }

// class _SecondStageViewBodyState extends State<SecondStageViewBody> {
//   bool isCameraOpen = false;
//   bool isComputerOpen = false;

//   bool isPasswordCorrect = false;
//   bool showFileIcon = false;
//   bool isMonsterPresent = false;

//   // حالة تحميل الصوت
// static const int soundLoadingDuration = 20;

// Timer? _soundTimer;

// int soundSecondsRemaining = 0;

// bool get isSoundLoading => soundSecondsRemaining > 0;

// void startSoundLoading() {
//   if (isSoundLoading) return;

//   setState(() {
//     soundSecondsRemaining = soundLoadingDuration;
//   });

//   _soundTimer?.cancel();

//   _soundTimer = Timer.periodic(
//     const Duration(seconds: 1),
//     (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       if (soundSecondsRemaining <= 1) {
//         timer.cancel();

//         setState(() {
//           soundSecondsRemaining = 0;
//         });

//         // TODO: تشغيل ملف الصوت بعد انتهاء التحميل.

//         return;
//       }

//       setState(() {
//         soundSecondsRemaining--;
//       });
//     },
//   );
// }

// @override
// void dispose() {
//   _soundTimer?.cancel();
//   super.dispose();
// }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//         final height = constraints.maxHeight;

//         return Stack(
//           fit: StackFit.expand,
//           children: [
//             // خلفية المرحلة
//             const VideoWidget(),
//             Positioned(left: 20, bottom: 20, child: PowerButtonWidget()),
//             // واجهة كاميرات المراقبة
//      if (isCameraOpen)
//   Positioned.fill(
//     child: CameraSecurity(
//       isMonsterPresent: isMonsterPresent,
//       onRoomTap: (roomName) {
//         debugPrint('تم الضغط على: $roomName');
//       },

//       // حالة عداد الصوت تأتي من الشاشة الأساسية
//       isSoundLoading: isSoundLoading,
//       soundSecondsRemaining: soundSecondsRemaining,
//       onSoundTap: startSoundLoading,
//     ),
//   ),

//             // شاشة الكمبيوتر
//             if (isComputerOpen)
//               Positioned.fill(
//                 child: ComputerScreen(
//                   onCorrectPassword: () {
//                     setState(() {
//                       isPasswordCorrect = true;
//                       isComputerOpen = false;
//                       showFileIcon = true;
//                     });
//                   },
//                 ),
//               ),

//             // المؤقت
//             Positioned(
//               top: height * 0.025,
//               left: width * 0.5,
//               child: Text(
//                 '02:59',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: width * 0.018,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),

//             // زر الكمبيوتر
//             Positioned(
//               right: width * 0.035,
//               bottom: height * 0.15,
//               child: IconButton(
//                 onPressed: () {
//                   // ممنوع فتح الكمبيوتر أثناء فتح الكاميرا
//                   if (isCameraOpen || isPasswordCorrect) return;

//                   setState(() {
//                     isComputerOpen = !isComputerOpen;
//                   });
//                 },
//                 icon: Icon(
//                   isComputerOpen ? Icons.close : Icons.computer_sharp,
//                   color: isPasswordCorrect ? Colors.grey : Colors.white,
//                   size: width * 0.035,
//                 ),
//               ),
//             ),

//             // زر الكاميرا
//             Positioned(
//               right: width * 0.035,
//               bottom: height * 0.035,
//               child: IconButton(
//                 onPressed: () {
//                   // ممنوع فتح الكاميرا أثناء فتح الكمبيوتر
//                   if (isComputerOpen) return;

//                   setState(() {
//                     isCameraOpen = !isCameraOpen;
//                   });
//                 },
//                 icon: Icon(
//                   isCameraOpen ? Icons.close : Icons.camera_alt_outlined,
//                   color: Colors.white,
//                   size: width * 0.035,
//                 ),
//               ),
//             ),

//             // الملف السري بعد إدخال كلمة المرور الصحيحة
//             if (showFileIcon)
//               Positioned(
//                 top: height * 0.025,
//                 left: width * 0.025,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.insert_drive_file,
//                       color: Colors.amber,
//                       size: width * 0.025,
//                     ),
//                     SizedBox(width: width * 0.005),
//                     Text(
//                       'Secret_File',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: width * 0.015,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
