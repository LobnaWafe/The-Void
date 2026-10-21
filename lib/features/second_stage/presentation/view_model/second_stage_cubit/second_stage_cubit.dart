
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:the_void/features/second_stage/domain/monster_movement_manager.dart';
import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_state.dart';

class SecondStageCubit extends Cubit<SecondStageState> {
  SecondStageCubit({
    MonsterMovementManager? monsterMovementManager,
  })  : _monsterManager =
            monsterMovementManager ?? MonsterMovementManager(),
        super(const SecondStageInitial());

  final MonsterMovementManager _monsterManager;

  Timer? _stageTimer;
  Timer? _movementTimer;

  static const int stageDurationSeconds = 180;

  bool _started = false;

  Duration get _elapsedTime {
    if (state is SecondStageInProgress) {
      final currentState = state as SecondStageInProgress;

      return Duration(seconds: currentState.elapsedSeconds);
    }

    return Duration.zero;
  }

  // بدء المرحلة.
  void startStage() {
    if (_started || isClosed) return;

    _started = true;

    emit(const SecondStageInProgress());

    _stageTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onStageTick(),
    );
  }

  // تحديث المؤقت ومراقبة وقت ظهور الوحش.
  void _onStageTick() {
    if (isClosed || state is! SecondStageInProgress) {
      return;
    }

    final currentState = state as SecondStageInProgress;

    final elapsedSeconds = currentState.elapsedSeconds + 1;

    final remainingSeconds =
        stageDurationSeconds - elapsedSeconds;

    final elapsedTime = Duration(seconds: elapsedSeconds);

    // انتهاء الوقت يوقف المؤقت وحركة الوحش.
    if (remainingSeconds <= 0) {
      _stageTimer?.cancel();
      _movementTimer?.cancel();

      emit(
        SecondStageInProgress(
          elapsedSeconds: stageDurationSeconds,
          remainingSeconds: 0,
          monsterRoom: currentState.monsterRoom,
          selectedCameraRoom: currentState.selectedCameraRoom,
          soundCooldownRemaining: 0,
          isProtectedFromAttack: false,
        ),
      );

      return;
    }

    // تحديث الوقت والحماية وفترة إعادة استخدام الصوت.
    emit(
      SecondStageInProgress(
        elapsedSeconds: elapsedSeconds,
        remainingSeconds: remainingSeconds,
        monsterRoom: currentState.monsterRoom,
        selectedCameraRoom: currentState.selectedCameraRoom,
        soundCooldownRemaining: _monsterManager
            .getSoundCooldownRemaining(elapsedTime)
            .inSeconds,
        isProtectedFromAttack:
            _monsterManager.isProtectedAt(elapsedTime),
      ),
    );

    // ظهور الوحش بعد مرور أول 30 ثانية.
    if (!_monsterManager.hasAppeared &&
        _monsterManager.canAppear(elapsedTime)) {
      final room = _monsterManager.appear(elapsedTime);

      final updatedState = state as SecondStageInProgress;

      emit(
        SecondStageInProgress(
          elapsedSeconds: updatedState.elapsedSeconds,
          remainingSeconds: updatedState.remainingSeconds,
          monsterRoom: room,
          selectedCameraRoom: updatedState.selectedCameraRoom,
          soundCooldownRemaining:
              updatedState.soundCooldownRemaining,
          isProtectedFromAttack:
              updatedState.isProtectedFromAttack,
        ),
      );

      debugPrint('ظهر الوحش في الغرفة $room');

      // بدء الحركة التلقائية بعد ظهور الوحش.
      _scheduleNextMovement();
    }
  }

  // جدولة حركة الوحش القادمة.
  void _scheduleNextMovement() {
    _movementTimer?.cancel();

    if (isClosed ||
        state is! SecondStageInProgress ||
        !_monsterManager.hasAppeared) {
      return;
    }

    final currentState = state as SecondStageInProgress;

    if (currentState.remainingSeconds <= 0) {
      return;
    }

    final delay = _monsterManager.getNextMovementDelay();

    _movementTimer = Timer(delay, () {
      if (isClosed ||
          state is! SecondStageInProgress ||
          !_monsterManager.hasAppeared) {
        return;
      }

      final latestState = state as SecondStageInProgress;

      if (latestState.remainingSeconds <= 0) {
        return;
      }

      final newRoom = _monsterManager.moveToNextRoom();

      emit(
        SecondStageInProgress(
          elapsedSeconds: latestState.elapsedSeconds,
          remainingSeconds: latestState.remainingSeconds,
          monsterRoom: newRoom,
          selectedCameraRoom: latestState.selectedCameraRoom,
          soundCooldownRemaining:
              latestState.soundCooldownRemaining,
          isProtectedFromAttack:
              latestState.isProtectedFromAttack,
        ),
      );

      debugPrint('انتقل الوحش إلى الغرفة $newRoom');

      // جدولة الحركة التالية.
      _scheduleNextMovement();
    });
  }

  // تغيير الكاميرا التي يشاهدها اللاعب.
  void selectCameraRoom(int roomNumber) {
    if (isClosed ||
        state is! SecondStageInProgress ||
        roomNumber < 1 ||
        roomNumber > 5) {
      return;
    }

    final currentState = state as SecondStageInProgress;

    emit(
      SecondStageInProgress(
        elapsedSeconds: currentState.elapsedSeconds,
        remainingSeconds: currentState.remainingSeconds,
        monsterRoom: currentState.monsterRoom,
        selectedCameraRoom: roomNumber,
        soundCooldownRemaining:
            currentState.soundCooldownRemaining,
        isProtectedFromAttack:
            currentState.isProtectedFromAttack,
      ),
    );
  }

  // تشغيل الصوت لإبعاد الوحش.
  bool activateSound() {
    if (isClosed || state is! SecondStageInProgress) {
      return false;
    }

    final currentState = state as SecondStageInProgress;

    if (currentState.remainingSeconds <= 0) {
      return false;
    }

    final elapsedTime = _elapsedTime;

    final success = _monsterManager.activateSound(
      elapsedTime: elapsedTime,
      attackStarted: false,
    );

    if (!success) {
      return false;
    }

    // مكان استدعاء ملف الصوت لاحقًا.
    _playSoundEffect();

    // تحديث حالة الوحش بعد تشغيل الصوت.
    emit(
      SecondStageInProgress(
        elapsedSeconds: currentState.elapsedSeconds,
        remainingSeconds: currentState.remainingSeconds,
        monsterRoom: _monsterManager.currentRoom,
        selectedCameraRoom: currentState.selectedCameraRoom,
        soundCooldownRemaining: _monsterManager
            .getSoundCooldownRemaining(elapsedTime)
            .inSeconds,
        isProtectedFromAttack:
            _monsterManager.isProtectedAt(elapsedTime),
      ),
    );

    // إعادة جدولة حركة الوحش من موقعه الجديد.
    _scheduleNextMovement();

    debugPrint('تم تشغيل الصوت وإبعاد الوحش');

    return true;
  }

  // مكان إضافة تشغيل ملف الصوت لاحقًا.
  void _playSoundEffect() {
    // TODO:
    // استدعاء ملف الصوت هنا بعد تجهيز الأصول.
    // مثال: assets/audios/security_sound.mp3
  }

  // إنهاء المرحلة بنجاح.
  void completeStage() {
    if (isClosed || state is! SecondStageInProgress) {
      return;
    }

    _stopTimers();

    emit(const SecondStageSuccess());
  }

  // إنهاء المرحلة بالخسارة.
  void failStage() {
    if (isClosed || state is! SecondStageInProgress) {
      return;
    }

    _stopTimers();

    emit(const SecondStageFailure());
  }

  // إيقاف المؤقتات.
  void _stopTimers() {
    _stageTimer?.cancel();
    _movementTimer?.cancel();

    _stageTimer = null;
    _movementTimer = null;
  }

  @override
  Future<void> close() {
    _stopTimers();

    return super.close();
  }
}

