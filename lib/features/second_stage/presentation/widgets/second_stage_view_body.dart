import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/core/utlis/assets_image.dart';
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

class _SecondStageViewBodyState extends State<SecondStageViewBody>
    with SingleTickerProviderStateMixin {
  late final SecondStageCubit _cubit;

  late final AnimationController _attackAnimationController;
  late final Animation<double> _attackScaleAnimation;

  bool isCameraOpen = false;
  bool isComputerOpen = false;
  bool isPasswordCorrect = false;
  bool showFileIcon = false;
  bool isPowerDepleted = false;

  late final AudioPlayer _powerAlarmPlayer;
  late final AudioPlayer _repelSoundPlayer;
  late final AudioPlayer _footstepsPlayer;
  late final AudioPlayer _attackPlayer;
  late final AudioPlayer _backgroundPlayer;
  // late final AudioPlayer _backgroundPlayerPowerOff;

  Timer? _restartTimer;

  int? _lastMonsterRoom;
  bool _wasAttackStarted = false;

  static const Duration _restartDelay = Duration(seconds: 3);

  static const String _powerAlarmSound = 'audios/alarm_of_monster.mp3';

  static const String _repelSound = 'audios/mouse_squeak.mp3';

  static const String _footstepsSound = 'audios/foot_steps_monster.mp3';

  static const String _attackSound = 'audios/attack_monster.mp3';

  static const String _backgroundsoundPowerOff =
      'audios/room_secondstage_power_off.mp3';

  static const String _backgroundSound = 'audios/room_seconstage.mp3';

  static const String _monsterAttackImage =
      'assets/images/second_stage_images/monster_attack.png';

  @override
  void initState() {
    super.initState();

    _cubit = SecondStageCubit();

    _attackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _attackScaleAnimation = Tween<double>(begin: 0.35, end: 2).animate(
      CurvedAnimation(parent: _attackAnimationController, curve: Curves.easeIn),
    );

    _backgroundPlayer = AudioPlayer();
    _powerAlarmPlayer = AudioPlayer();
    _repelSoundPlayer = AudioPlayer();
    _footstepsPlayer = AudioPlayer();
    _attackPlayer = AudioPlayer();
    //  _backgroundPlayerPowerOff=AudioPlayer();

    unawaited(_playBackgroundSound());

    _cubit.startStage();
  }

  // =========================================================
  // صوت خلفية غرفة الأمن
  // =========================================================

  Future<void> _playBackgroundSound() async {
    if (isPowerDepleted || !mounted) return;

    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(
        AssetSource(
          isPowerDepleted ? _backgroundsoundPowerOff : _backgroundSound,
        ),
      );
    } catch (error) {
      debugPrint('تعذر تشغيل صوت الخلفية: $error');
    }
  }

  // =========================================================
  // تشغيل الأصوات
  // =========================================================

  Future<void> _playLoop(AudioPlayer player, String assetPath) async {
    try {
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(assetPath));
    } catch (error) {
      debugPrint('تعذر تشغيل الصوت $assetPath: $error');
    }
  }

  Future<void> _playOnce(AudioPlayer player, String assetPath) async {
    try {
      await player.stop();
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(AssetSource(assetPath));
    } catch (error) {
      debugPrint('تعذر تشغيل الصوت $assetPath: $error');
    }
  }

  Future<void> _stopPlayer(AudioPlayer player) async {
    try {
      await player.stop();
    } catch (error) {
      debugPrint('تعذر إيقاف الصوت: $error');
    }
  }

  Future<void> _stopAllSounds() async {
    await Future.wait([
      _stopPlayer(_backgroundPlayer),
      _stopPlayer(_powerAlarmPlayer),
      _stopPlayer(_repelSoundPlayer),
      _stopPlayer(_footstepsPlayer),
      _stopPlayer(_attackPlayer),
    ]);
  }

  // =========================================================
  // التعامل مع أحداث الوحش
  // =========================================================

  void _handleGameState(SecondStageState state) {
    if (state is SecondStageInProgress) {
      final currentRoom = state.monsterRoom;

      // دخل الوحش الغرفة الخامسة.
      if (currentRoom == 5 && _lastMonsterRoom != 5) {
        unawaited(_playLoop(_footstepsPlayer, _footstepsSound));
      }

      // خرج الوحش من الغرفة الخامسة.
      if (_lastMonsterRoom == 5 && currentRoom != 5) {
        unawaited(_stopPlayer(_footstepsPlayer));
      }

      // بدأ الهجوم.
      if (state.isAttackStarted && !_wasAttackStarted) {
        _onAttackStarted();
      }

      _lastMonsterRoom = currentRoom;
      _wasAttackStarted = state.isAttackStarted;

      return;
    }

    if (state is SecondStageSuccess || state is SecondStageFailure) {
      _restartTimer?.cancel();

      unawaited(_stopAllSounds());

      _lastMonsterRoom = null;
      _wasAttackStarted = false;
    }

    if (state is SecondStageFailure) {
      _prepareRestart();

      _restartTimer = Timer(_restartDelay, _restartStage);
    }
  }

  void _onAttackStarted() {
    if (!mounted) return;

    setState(() {
      isCameraOpen = false;
      isComputerOpen = false;
    });

    // تكبير صورة الوحش من البداية حتى تملأ الشاشة.
    _attackAnimationController
      ..stop()
      ..reset();

    _attackAnimationController.forward();

    // إيقاف الخلفية والخطوات والإنذارات والأصوات الأخرى.
    unawaited(_stopPlayer(_backgroundPlayer));
    unawaited(_stopPlayer(_footstepsPlayer));
    unawaited(_stopPlayer(_powerAlarmPlayer));
    unawaited(_stopPlayer(_repelSoundPlayer));

    // تشغيل صوت الهجوم.
    unawaited(_playOnce(_attackPlayer, _attackSound));
  }

  // =========================================================
  // إعادة المرحلة بعد الخسارة
  // =========================================================

  void _prepareRestart() {
    if (!mounted) return;

    _attackAnimationController
      ..stop()
      ..reset();

    setState(() {
      isCameraOpen = false;
      isComputerOpen = false;
      isPasswordCorrect = false;
      showFileIcon = false;
      isPowerDepleted = false;
    });
  }

  void _restartStage() {
    if (!mounted) return;

    _attackAnimationController
      ..stop()
      ..reset();

    setState(() {
      isCameraOpen = false;
      isComputerOpen = false;
      isPasswordCorrect = false;
      showFileIcon = false;
      isPowerDepleted = false;
    });

    _lastMonsterRoom = null;
    _wasAttackStarted = false;

    // إعادة تشغيل الخلفية بعد إعادة المرحلة.
    unawaited(_playBackgroundSound());

    _cubit.restartStage();
  }

  // =========================================================
  // استخدام صوت إبعاد الوحش
  // =========================================================

  void _handleSoundTap() {
    final success = _cubit.activateSound();

    // if (!success) {
    //   debugPrint('الصوت غير متاح حاليًا.');
    //   return;
    // }

    unawaited(_playOnce(_repelSoundPlayer, _repelSound));
  }

  // =========================================================
  // التخلص من الموارد
  // =========================================================

  @override
  void dispose() {
    _restartTimer?.cancel();

    _attackAnimationController.dispose();

    _cubit.close();

    unawaited(_backgroundPlayer.dispose());
    unawaited(_powerAlarmPlayer.dispose());
    unawaited(_repelSoundPlayer.dispose());
    unawaited(_footstepsPlayer.dispose());
    unawaited(_attackPlayer.dispose());

    super.dispose();
  }

  // =========================================================
  // واجهة المرحلة
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SecondStageCubit, SecondStageState>(
        listener: (context, state) {
          _handleGameState(state);

          if (state is SecondStageSuccess) {
            debugPrint('انتهت المرحلة بنجاح.');
          }

          if (state is SecondStageFailure) {
            debugPrint('انتهت المرحلة بالخسارة. ستبدأ جولة جديدة.');
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
            return const ColoredBox(
              color: Colors.black,
              child: Center(
                child: Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            );
          }

          final gameState = state as SecondStageInProgress;
          final isAttacking = gameState.isAttackStarted;

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية غرفة الأمن.
                  if (isPowerDepleted)
                    Positioned.fill(
                      child: Image.asset(
                        AssetsImage.secondStageRoomPowerOffImage,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    VideoWidget(file: gameState.hasFile),

                  // صورة الوحش أثناء الهجوم مع التكبير التدريجي.
                  if (isAttacking)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _attackScaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _attackScaleAnimation.value,
                              child: child,
                            );
                          },
                          child: Image.asset(
                            _monsterAttackImage,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                'تعذر تحميل صورة الهجوم: '
                                '$_monsterAttackImage',
                              );

                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),

                  // إخفاء أدوات التفاعل أثناء الهجوم.
                  if (!isAttacking) ...[
                    // زر الطاقة.
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: PowerButtonWidget(
                        key: const ValueKey('second_stage_power'),
                        onPowerDepleted: () {
                          setState(() {
                            isPowerDepleted = true;
                            isCameraOpen = false;
                            isComputerOpen = false;
                          });

                          // // تشغيل صوت الخلفية بعد انقطاع الكهرباء.
                          // unawaited(_playPowerOffBackgroundSound());
                        },
                        onAlarmChanged: (shouldPlay) {
                          if (shouldPlay && !isPowerDepleted) {
                            unawaited(
                              _playLoop(_powerAlarmPlayer, _powerAlarmSound),
                            );
                          } else {
                            unawaited(_stopPlayer(_powerAlarmPlayer));
                          }
                        },
                      ),
                    ),

                    // واجهة الكاميرات.
                    if (isCameraOpen)
                      Positioned.fill(
                        child: CameraSecurity(
                          selectedRoom: gameState.selectedCameraRoom,
                          isMonsterPresent: gameState.isMonsterInSelectedRoom,
                          onRoomTap: _cubit.selectCameraRoom,
                          isSoundLoading: !gameState.canUseSound,
                          soundSecondsRemaining:
                              gameState.soundCooldownRemaining,
                          onSoundTap: _handleSoundTap,
                        ),
                      ),

                    // شاشة الكمبيوتر.
                    if (isComputerOpen)
                      Positioned.fill(
                        child: ComputerScreen(
                          onCorrectPassword: () {
                            _cubit.obtainFile();

                            setState(() {
                              isPasswordCorrect = true;
                              isComputerOpen = false;
                              showFileIcon = true;
                            });
                          },
                        ),
                      ),
                  ],

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
                  // if (gameState.monsterRoom == 5)
                  //   Positioned(
                  //     top: height * 0.08,
                  //     left: width * 0.5,
                  //     child: Column(
                  //       children: [
                  //         Text(
                  //           isAttacking
                  //               ? 'ATTACK!'
                  //               : 'FOOTSTEPS NEARBY',
                  //           style: TextStyle(
                  //             color: Colors.red,
                  //             fontSize: width * 0.018,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //         if (gameState.attackSecondsRemaining > 0)
                  //           Text(
                  //             gameState.formattedAttackTime,
                  //             style: TextStyle(
                  //               color: Colors.red,
                  //               fontSize: width * 0.025,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //       ],
                  //     ),
                  //   ),

                  // أزرار التفاعل.
                  if (!isAttacking) ...[
                    // زر الكمبيوتر.
                    Positioned(
                      right: width * 0.035,
                      bottom: height * 0.15,
                      child: IconButton(
                        onPressed: () {
                          if (isCameraOpen ||
                              isPasswordCorrect ||
                              isPowerDepleted) {
                            return;
                          }

                          setState(() {
                            isComputerOpen = !isComputerOpen;
                          });
                        },
                        icon: Icon(
                          isComputerOpen ? Icons.close : Icons.computer_sharp,
                          color: isPasswordCorrect || isPowerDepleted
                              ? Colors.grey
                              : Colors.white,
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
                          if (isComputerOpen || isPowerDepleted) {
                            return;
                          }

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
                          isCameraOpen
                              ? Icons.close
                              : Icons.camera_alt_outlined,
                          color: isPowerDepleted ? Colors.grey : Colors.white,
                          size: width * 0.035,
                        ),
                      ),
                    ),
                  ],

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

// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:the_void/core/utlis/assets_image.dart';

// import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_cubit.dart';
// import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_state.dart';

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
//   late final SecondStageCubit _cubit;

//   bool isCameraOpen = false;
//   bool isComputerOpen = false;

//   bool isPasswordCorrect = false;
//   bool showFileIcon = false;
//   bool isPowerDepleted = false;

//   // مشغلات الأصوات.
//   late final AudioPlayer _powerAlarmPlayer;
//   late final AudioPlayer _repelSoundPlayer;
//   late final AudioPlayer _footstepsPlayer;
//   late final AudioPlayer _attackPlayer;
//   late final AudioPlayer _backgroundPlayer;

//   Timer? _restartTimer;

//   int? _lastMonsterRoom;
//   bool _wasAttackStarted = false;

//   static const Duration _restartDelay = Duration(seconds: 3);

//   // =========================================================
//   // مسارات الأصوات والصورة
//   // عدلي المسارات لتطابق أسماء ملفاتك.
//   // =========================================================

//   static const String _powerAlarmSound = 'audios/alarm_of_monster.mp3';

//   static const String _repelSound = 'audios/mouse_squeak.mp3';

//   static const String _footstepsSound = 'audios/foot_steps_monster.mp3';

//   static const String _attackSound = 'audios/attack_monster.mp3';

//   static const String _monsterAttackImage =
//       'assets/images/second_stage_images/monster_attack.png';

//   //////
//   ///
  

//   @override
//   void initState() {
//     super.initState();

//     _cubit = SecondStageCubit();
//     _backgroundPlayer = AudioPlayer();

//     _playBackgroundSound();

//     _powerAlarmPlayer = AudioPlayer();
//     _repelSoundPlayer = AudioPlayer();
//     _footstepsPlayer = AudioPlayer();
//     _attackPlayer = AudioPlayer();

//     _cubit.startStage();
//   }

//   // background sound
//   Future<void> _playBackgroundSound() async {
//     if (isPowerDepleted) return;

//     try {
//       await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);

//       await _backgroundPlayer.play(AssetSource('room_seconstage.mp3'));
//     } catch (error) {
//       debugPrint('تعذر تشغيل صوت الخلفية: $error');
//     }
//   }

//   // =========================================================
//   // تشغيل الأصوات
//   // =========================================================

//   Future<void> _playLoop(AudioPlayer player, String assetPath) async {
//     try {
//       await player.stop();

//       await player.setReleaseMode(ReleaseMode.loop);

//       await player.play(AssetSource(assetPath));
//     } catch (error) {
//       debugPrint('تعذر تشغيل الصوت $assetPath: $error');
//     }
//   }

//   Future<void> _playOnce(AudioPlayer player, String assetPath) async {
//     try {
//       await player.stop();

//       await player.setReleaseMode(ReleaseMode.release);

//       await player.play(AssetSource(assetPath));
//     } catch (error) {
//       debugPrint('تعذر تشغيل الصوت $assetPath: $error');
//     }
//   }

//   Future<void> _stopPlayer(AudioPlayer player) async {
//     try {
//       await player.stop();
//     } catch (error) {
//       debugPrint('تعذر إيقاف الصوت: $error');
//     }
//   }

//   Future<void> _stopAllSounds() async {
//     await Future.wait([
//       _stopPlayer(_backgroundPlayer),
//       _stopPlayer(_powerAlarmPlayer),
//       _stopPlayer(_repelSoundPlayer),
//       _stopPlayer(_footstepsPlayer),
//       _stopPlayer(_attackPlayer),
//     ]);
//   }

//   // =========================================================
//   // التعامل مع أحداث الوحش
//   // =========================================================

//   void _handleGameState(SecondStageState state) {
//     if (state is SecondStageInProgress) {
//       final currentRoom = state.monsterRoom;

//       // دخل الوحش الغرفة الخامسة.
//       if (currentRoom == 5 && _lastMonsterRoom != 5 && !state.isAttackStarted) {
//         unawaited(_playLoop(_footstepsPlayer, _footstepsSound));
//       }

//       // خرج الوحش من الغرفة الخامسة.
//       if (_lastMonsterRoom == 5 && currentRoom != 5) {
//         unawaited(_stopPlayer(_footstepsPlayer));
//       }

//       // بدأ الهجوم.
//       if (state.isAttackStarted && !_wasAttackStarted) {
//         _onAttackStarted();
//       }

//       _lastMonsterRoom = currentRoom;
//       _wasAttackStarted = state.isAttackStarted;

//       return;
//     }

//     // انتهت المرحلة بالفوز أو الخسارة.
//     if (state is SecondStageSuccess || state is SecondStageFailure) {
//       _restartTimer?.cancel();

//       unawaited(_stopAllSounds());

//       _lastMonsterRoom = null;
//       _wasAttackStarted = false;
//     }

//     if (state is SecondStageFailure) {
//       _prepareRestart();

//       _restartTimer = Timer(_restartDelay, _restartStage);
//     }
//   }

//   void _onAttackStarted() {
//     if (mounted) {
//       setState(() {
//         isCameraOpen = false;
//         isComputerOpen = false;
//       });
//     }

//     // الهجوم ينهي المرحلة؛ أوقفي الخلفية وباقي الأصوات.
//     unawaited(_stopPlayer(_backgroundPlayer));
//     unawaited(_stopPlayer(_footstepsPlayer));
//     unawaited(_stopPlayer(_powerAlarmPlayer));
//     unawaited(_stopPlayer(_repelSoundPlayer));

//     // تشغيل صوت الهجوم.
//     unawaited(_playOnce(_attackPlayer, _attackSound));
//   }

//   // =========================================================
//   // إعادة المرحلة بعد الخسارة
//   // =========================================================

//   void _prepareRestart() {
//     if (!mounted) return;

//     setState(() {
//       isCameraOpen = false;
//       isComputerOpen = false;

//       isPasswordCorrect = false;
//       showFileIcon = false;
//       isPowerDepleted = false;
//     });
//   }

//   void _restartStage() {
//     if (!mounted) return;

//     setState(() {
//       isCameraOpen = false;
//       isComputerOpen = false;

//       isPasswordCorrect = false;
//       showFileIcon = false;
//       isPowerDepleted = false;
//     });

//     _lastMonsterRoom = null;
//     _wasAttackStarted = false;

//     _cubit.restartStage();
//   }

//   // =========================================================
//   // استخدام صوت إبعاد الوحش
//   // =========================================================

//   void _handleSoundTap() {
//     final success = _cubit.activateSound();

//     if (!success) {
//       debugPrint('الصوت غير متاح حاليًا.');
//       return;
//     }

//     unawaited(_playOnce(_repelSoundPlayer, _repelSound));
//   }

//   // =========================================================
//   // التخلص من الموارد
//   // =========================================================

//   @override
//   void dispose() {
//     _restartTimer?.cancel();

//     _cubit.close();

//     unawaited(_backgroundPlayer.dispose());
//     unawaited(_powerAlarmPlayer.dispose());
//     unawaited(_repelSoundPlayer.dispose());
//     unawaited(_footstepsPlayer.dispose());
//     unawaited(_attackPlayer.dispose());

//     super.dispose();
//   }

//   // =========================================================
//   // واجهة المرحلة
//   // =========================================================

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _cubit,
//       child: BlocConsumer<SecondStageCubit, SecondStageState>(
//         listener: (context, state) {
//           _handleGameState(state);

//           if (state is SecondStageSuccess) {
//             debugPrint('انتهت المرحلة بنجاح.');
//           }

//           if (state is SecondStageFailure) {
//             debugPrint('انتهت المرحلة بالخسارة. ستبدأ جولة جديدة.');
//           }
//         },
//         builder: (context, state) {
//           if (state is SecondStageInitial) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (state is SecondStageSuccess) {
//             return const Center(
//               child: Text(
//                 'Stage Completed!',
//                 style: TextStyle(color: Colors.white, fontSize: 28),
//               ),
//             );
//           }

//           if (state is SecondStageFailure) {
//             return const ColoredBox(
//               color: Colors.black,
//               child: Center(
//                 child: Text(
//                   'GAME OVER',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 4,
//                   ),
//                 ),
//               ),
//             );
//           }

//           final gameState = state as SecondStageInProgress;

//           final isAttacking = gameState.isAttackStarted;

//           return LayoutBuilder(
//             builder: (context, constraints) {
//               final width = constraints.maxWidth;
//               final height = constraints.maxHeight;

//               return Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // خلفية غرفة الأمن.
//                   isPowerDepleted
//                       ? Positioned.fill(
//                           child: Image.asset(
//                             AssetsImage.secondStageRoomPowerOffImage,
//                           ),
//                         )
//                       : VideoWidget(file: gameState.hasFile),

//                   // صورة الوحش أثناء الهجوم.
//                   // تظهر فوق الخلفية وتحت عناصر الواجهة.
//                   if (isAttacking)
//                     Positioned.fill(
//                       child: IgnorePointer(
//                         child: Image.asset(
//                           _monsterAttackImage,
//                           fit: BoxFit.contain,
//                           filterQuality: FilterQuality.high,
//                           errorBuilder: (context, error, stackTrace) {
//                             debugPrint(
//                               'تعذر تحميل صورة الهجوم: '
//                               '$_monsterAttackImage',
//                             );

//                             return const SizedBox.shrink();
//                           },
//                         ),
//                       ),
//                     ),

//                   // إخفاء أدوات التفاعل أثناء الهجوم.
//                   if (!isAttacking) ...[
//                     // الطاقة.
//                     Positioned(
//                       left: 20,
//                       bottom: 20,
//                       child: PowerButtonWidget(
//                         onPowerDepleted: () {
//                           setState(() {
//                             isPowerDepleted = true;
//                             isCameraOpen = false;
//                             isComputerOpen = false;
//                           });

//                           unawaited(_stopPlayer(_backgroundPlayer));
//                         },
//                         onAlarmChanged: (shouldPlay) {
//                           if (shouldPlay) {
//                             unawaited(
//                               _playLoop(_powerAlarmPlayer, _powerAlarmSound),
//                             );
//                           } else {
//                             unawaited(_stopPlayer(_powerAlarmPlayer));
//                           }
//                         },
//                       ),
//                     ),

//                     // واجهة الكاميرات.
//                     if (isCameraOpen)
//                       Positioned.fill(
//                         child: CameraSecurity(
//                           selectedRoom: gameState.selectedCameraRoom,
//                           isMonsterPresent: gameState.isMonsterInSelectedRoom,
//                           onRoomTap: _cubit.selectCameraRoom,
//                           isSoundLoading: !gameState.canUseSound,
//                           soundSecondsRemaining:
//                               gameState.soundCooldownRemaining,
//                           onSoundTap: _handleSoundTap,
//                         ),
//                       ),

//                     // شاشة الكمبيوتر.
//                     if (isComputerOpen)
//                       Positioned.fill(
//                         child: ComputerScreen(
//                           onCorrectPassword: () {
//                             // تسجيل الملف داخل الـ Cubit.
//                             _cubit.obtainFile();

//                             setState(() {
//                               isPasswordCorrect = true;
//                               isComputerOpen = false;
//                               showFileIcon = true;
//                             });
//                           },
//                         ),
//                       ),
//                   ],

//                   // مؤقت المرحلة.
//                   Positioned(
//                     top: height * 0.025,
//                     left: width * 0.5,
//                     child: Text(
//                       gameState.formattedTime,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: width * 0.018,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                   // تحذير اقتراب الوحش.
//                   if (gameState.monsterRoom == 5)
//                     Positioned(
//                       top: height * 0.08,
//                       left: width * 0.5,
//                       child: Column(
//                         children: [
//                           Text(
//                             isAttacking ? 'ATTACK!' : 'FOOTSTEPS NEARBY',
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: width * 0.018,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if (gameState.attackSecondsRemaining > 0)
//                             Text(
//                               gameState.formattedAttackTime,
//                               style: TextStyle(
//                                 color: Colors.red,
//                                 fontSize: width * 0.025,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),

//                   // أزرار التفاعل.
//                   if (!isAttacking) ...[
//                     // زر الكمبيوتر.
//                     Positioned(
//                       right: width * 0.035,
//                       bottom: height * 0.15,
//                       child: IconButton(
//                         onPressed: () {
//                           if (isCameraOpen ||
//                               isPasswordCorrect ||
//                               isPowerDepleted) {
//                             return;
//                           }

//                           setState(() {
//                             isComputerOpen = !isComputerOpen;
//                           });
//                         },
//                         icon: Icon(
//                           isComputerOpen ? Icons.close : Icons.computer_sharp,
//                           color: isPasswordCorrect || isPowerDepleted
//                               ? Colors.grey
//                               : Colors.white,
//                           size: width * 0.035,
//                         ),
//                       ),
//                     ),

//                     // زر الكاميرا.
//                     Positioned(
//                       right: width * 0.035,
//                       bottom: height * 0.035,
//                       child: IconButton(
//                         onPressed: () {
//                           if (isComputerOpen || isPowerDepleted) {
//                             return;
//                           }

//                           setState(() {
//                             if (!isCameraOpen) {
//                               _cubit.selectCameraRoom(1);
//                               isCameraOpen = true;
//                             } else {
//                               isCameraOpen = false;
//                             }
//                           });
//                         },
//                         icon: Icon(
//                           isCameraOpen
//                               ? Icons.close
//                               : Icons.camera_alt_outlined,
//                           color: isPowerDepleted ? Colors.grey : Colors.white,
//                           size: width * 0.035,
//                         ),
//                       ),
//                     ),
//                   ],

//                   // الملف السري.
//                   if (showFileIcon)
//                     Positioned(
//                       top: height * 0.025,
//                       left: width * 0.025,
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.insert_drive_file,
//                             color: Colors.amber,
//                             size: width * 0.025,
//                           ),
//                           SizedBox(width: width * 0.005),
//                           Text(
//                             'Secret_File',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: width * 0.015,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
