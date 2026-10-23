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
  State<SecondStageViewBody> createState() =>
      _SecondStageViewBodyState();
}

class _SecondStageViewBodyState
    extends State<SecondStageViewBody>
    with SingleTickerProviderStateMixin {
  late final SecondStageCubit _cubit;

  late final AnimationController _attackAnimationController;

  late final Animation<double> _attackScaleAnimation;

  late final AudioPlayer _powerAlarmPlayer;

  late final AudioPlayer _repelSoundPlayer;

  late final AudioPlayer _footstepsPlayer;

  late final AudioPlayer _attackPlayer;

  late final AudioPlayer _backgroundPlayer;

  Timer? _restartTimer;

  bool isCameraOpen = false;

  bool isComputerOpen = false;

  bool isPasswordCorrect = false;

  bool showFileIcon = false;

  bool isPowerDepleted = false;

  int? _lastMonsterRoom;

  bool _wasAttackStarted = false;

  bool _isSoundLoading = false;
  int _soundSecondsRemaining = 0;
  Timer? _soundCooldownTimer;

  static const Duration _restartDelay =
      Duration(seconds: 3);

  static const String _powerAlarmSound =
      'audios/alarm_of_monster.mp3';

  static const String _repelSound =
      'audios/mouse_squeak.mp3';

  static const String _footstepsSound =
      'audios/foot_steps_monster.mp3';

  static const String _attackSound =
      'audios/attack_monster.mp3';

  static const String _backgroundSoundPowerOff =
      'audios/room_secondstage_power_off.mp3';

  static const String _backgroundSound =
      'audios/room_seconstage.mp3';

  static const String _monsterAttackImage =
      'assets/images/second_stage_images/monster_attack.png';


@override
  void initState() {
    super.initState();

    _cubit = SecondStageCubit();

    _attackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _attackScaleAnimation = Tween<double>(
      begin: 0.35,
      end: 2,
    ).animate(
      CurvedAnimation(
        parent: _attackAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _backgroundPlayer = AudioPlayer();
    _powerAlarmPlayer = AudioPlayer();
    _repelSoundPlayer = AudioPlayer();
    _footstepsPlayer = AudioPlayer();
    _attackPlayer = AudioPlayer();

    // منع تداخل أو إيقاف الأصوات ببعضها البعض
    final contextAudio = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none,
      ),
      // ios: AudioContextIOS(
      //   category: AVAudioSessionCategory.playback,
      //   options: [AVAudioSessionOptions.mixWithOthers],
      // ),
    );

    for (var player in [
      _backgroundPlayer,
      _powerAlarmPlayer,
      _repelSoundPlayer,
      _footstepsPlayer,
      _attackPlayer
    ]) {
      player.setAudioContext(contextAudio);
    }

    unawaited(_playBackgroundSound());

    _cubit.startStage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحميل صورة انقطاع الكهرباء مسبقاً في الذاكرة لتظهر فوراً عند انقطاعها
    precacheImage(
      const AssetImage(AssetsImage.secondStageRoomPowerOffImage),
      context,
    );
  }

  /// تشغيل صوت الخلفية بحسب حالة الطاقة.
  Future<void> _playBackgroundSound() async {
    if (!mounted) {
      return;
    }

    final sound = isPowerDepleted
        ? _backgroundSoundPowerOff
        : _backgroundSound;

    try {
      await _backgroundPlayer.stop();

      await _backgroundPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await _backgroundPlayer.play(
        AssetSource(sound),
      );
    } catch (error) {
      debugPrint(
        'تعذر تشغيل صوت الخلفية: $error',
      );
    }
  }

  /// تشغيل صوت متكرر.
  Future<void> _playLoop(
    AudioPlayer player,
    String assetPath,
  ) async {
    try {
      await player.stop();

      await player.setReleaseMode(
        ReleaseMode.loop,
      );

      await player.play(
        AssetSource(assetPath),
      );
    } catch (error) {
      debugPrint(
        'تعذر تشغيل الصوت $assetPath: $error',
      );
    }
  }

  /// تشغيل صوت مرة واحدة.
  Future<void> _playOnce(
    AudioPlayer player,
    String assetPath,
  ) async {
    try {
      await player.stop();

      await player.setReleaseMode(
        ReleaseMode.release,
      );

      await player.play(
        AssetSource(assetPath),
      );
    } catch (error) {
      debugPrint(
        'تعذر تشغيل الصوت $assetPath: $error',
      );
    }
  }

  Future<void> _stopPlayer(AudioPlayer player) async {
    try {
      await player.stop();
    } catch (error) {
      debugPrint(
        'تعذر إيقاف الصوت: $error',
      );
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

  /// متابعة تغيّر حالة المرحلة.
  void _handleGameState(SecondStageState state) {
    if (state is SecondStageInProgress) {
      final currentRoom = state.monsterRoom;

      if (currentRoom == 5 && _lastMonsterRoom != 5) {
        unawaited(
          _playLoop(
            _footstepsPlayer,
            _footstepsSound,
          ),
        );
      }

      if (_lastMonsterRoom == 5 && currentRoom != 5) {
        unawaited(
          _stopPlayer(_footstepsPlayer),
        );
      }

      if (state.isAttackStarted && !_wasAttackStarted) {
        _onAttackStarted();
      }

      _lastMonsterRoom = currentRoom;

      _wasAttackStarted = state.isAttackStarted;

      return;
    }

    if (state is SecondStageSuccess ||
        state is SecondStageFailure) {
      _restartTimer?.cancel();

      unawaited(_stopAllSounds());

      _lastMonsterRoom = null;

      _wasAttackStarted = false;
    }

    if (state is SecondStageFailure) {
      _prepareRestart();

      _restartTimer = Timer(
        _restartDelay,
        _restartStage,
      );
    } else{
      //go to chating room
    }
  }

  /// بدء مشهد الهجوم.
  void _onAttackStarted() {
    if (!mounted) {
      return;
    }

    setState(() {
      isCameraOpen = false;

      isComputerOpen = false;
    });

    _attackAnimationController
      ..stop()
      ..reset();

    _attackAnimationController.forward();

    unawaited(_stopPlayer(_backgroundPlayer));

    unawaited(_stopPlayer(_footstepsPlayer));

    unawaited(_stopPlayer(_powerAlarmPlayer));

    unawaited(_stopPlayer(_repelSoundPlayer));

    unawaited(
      _playOnce(
        _attackPlayer,
        _attackSound,
      ),
    );
  }

  /// تجهيز واجهة شاشة الخسارة.
  ///
  /// لا نعيد تشغيل الطاقة هنا؛ إعادة الضبط الحقيقية
  /// تحدث عند بدء المحاولة الجديدة.
  void _prepareRestart() {
    if (!mounted) {
      return;
    }

    _attackAnimationController
      ..stop()
      ..reset();

    setState(() {
      isCameraOpen = false;

      isComputerOpen = false;

      isPasswordCorrect = false;

      showFileIcon = false;
    });
  }

  /// بدء محاولة جديدة بعد شاشة GAME OVER.
  void _restartStage() {
    if (!mounted) {
      return;
    }

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

    _cubit.restartStage();

    unawaited(_playBackgroundSound());
  }

  /// استخدام صوت إبعاد الوحش.
  void _handleSoundTap() {
    if (isPowerDepleted || _isSoundLoading) {
      return;
    }

    final success = _cubit.activateSound();

    if (!success) {
      return;
    }

    unawaited(
      _playOnce(
        _repelSoundPlayer,
        _repelSound,
      ),
    );

    // بدء الـ Cooldown لمدة 20 ثانية
    setState(() {
      _isSoundLoading = true;
      _soundSecondsRemaining = 20;
    });

    _soundCooldownTimer?.cancel();
    _soundCooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          if (_soundSecondsRemaining > 1) {
            _soundSecondsRemaining--;
          } else {
            _isSoundLoading = false;
            _soundSecondsRemaining = 0;
            timer.cancel();
          }
        });
      },
    );
  }
  /// انتهاء الطاقة.
  void _handlePowerDepleted() {
    if (!mounted || isPowerDepleted) {
      return;
    }

    setState(() {
      isPowerDepleted = true;

      isCameraOpen = false;

      isComputerOpen = false;
    });

    unawaited(_stopPlayer(_powerAlarmPlayer));

    unawaited(_stopPlayer(_footstepsPlayer));

    unawaited(_playBackgroundSound());
  }

  /// تغيير حالة إنذار الطاقة.
  void _handleAlarmChanged(bool shouldPlay) {
    if (shouldPlay && !isPowerDepleted) {
      unawaited(
        _playLoop(
          _powerAlarmPlayer,
          _powerAlarmSound,
        ),
      );
    } else {
      unawaited(
        _stopPlayer(_powerAlarmPlayer),
      );
    }
  }

  @override
  void dispose() {
    _restartTimer?.cancel();

   _soundCooldownTimer?.cancel();
    _attackAnimationController.dispose();

    _cubit.close();

    unawaited(_backgroundPlayer.dispose());

    unawaited(_powerAlarmPlayer.dispose());

    unawaited(_repelSoundPlayer.dispose());

    unawaited(_footstepsPlayer.dispose());

    unawaited(_attackPlayer.dispose());

    super.dispose();
  }

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
            debugPrint(
              'انتهت المرحلة بالخسارة. ستبدأ محاولة جديدة.',
            );
          }
        },
        builder: (context, state) {
          if (state is SecondStageInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SecondStageSuccess) {
            return const ColoredBox(
              color: Colors.black,
              child: Center(
                child: Text(
                  'STAGE COMPLETED',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
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
                
                    /// خلفية الغرفة.
                  if (isPowerDepleted)
                    Positioned.fill(
                      child: Image.asset(
                        AssetsImage.secondStageRoomPowerOffImage,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                     VideoWidget(
                      key: ValueKey('stable_background_video'),
                     file: gameState.hasFile, // استبدلها بـ gameState.hasFile حسب متغيرك
                    ),

                  /// صورة هجوم الوحش.
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
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
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

                  /// عناصر التحكم التي تختفي أثناء الهجوم.
                  if (!isAttacking) ...[
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: PowerButtonWidget(
                        key: const ValueKey(
                          'second_stage_power',
                        ),
                        isPowerDepleted: isPowerDepleted,
                        onPowerDepleted: _handlePowerDepleted,
                        onAlarmChanged: _handleAlarmChanged,
                      ),
                    ),

                   
                    /// شاشة الكاميرات.
                if (isCameraOpen)
                  Positioned.fill(
                    child: CameraSecurity(
                      selectedRoom:
                          gameState.selectedCameraRoom,
                      isMonsterPresent:
                          gameState.isMonsterInSelectedRoom,
                      onRoomTap: _cubit.selectCameraRoom,

                      /// تمرير حالة التحميل والثواني المتبقية
                      isSoundLoading: _isSoundLoading,
                      soundSecondsRemaining: _soundSecondsRemaining,

                      onSoundTap: _handleSoundTap,
                    ),
                  ),

                    /// شاشة الكمبيوتر.
                    if (isComputerOpen)
                      Positioned.fill(
                        child: ComputerScreen(
                          onCorrectPassword: () {
                            if (isPowerDepleted ||
                                isPasswordCorrect) {
                              return;
                            }

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

                  /// عداد الوقت.
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

                  /// زر الكمبيوتر.
                  if (!isAttacking)
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
                          isComputerOpen
                              ? Icons.close
                              : Icons.computer_sharp,
                          color: isPasswordCorrect ||
                                  isPowerDepleted
                              ? Colors.grey
                              : Colors.white,
                          size: width * 0.035,
                        ),
                      ),
                    ),

                  /// زر الكاميرات.
                  if (!isAttacking)
                    Positioned(
                      right: width * 0.035,
                      bottom: height * 0.035,
                      child: IconButton(
                        onPressed: () {
                          if (isComputerOpen ||
                              isPowerDepleted) {
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
                          color: isPowerDepleted
                              ? Colors.grey
                              : Colors.white,
                          size: width * 0.035,
                        ),
                      ),
                    ),

                  /// أيقونة الملف بعد الحصول عليه.
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
                          SizedBox(
                            width: width * 0.005,
                          ),
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
