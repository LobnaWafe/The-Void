import 'package:flutter/foundation.dart';

@immutable
abstract class SecondStageState {
  const SecondStageState();
}

// الحالة الأولية قبل بداية المرحلة.
class SecondStageInitial extends SecondStageState {
  const SecondStageInitial();
}

// الحالة أثناء اللعب.
class SecondStageInProgress extends SecondStageState {
  const SecondStageInProgress({
    this.elapsedSeconds = 0,
    this.remainingSeconds = 180,
    this.monsterRoom,
    this.selectedCameraRoom = 1,
    this.soundCooldownRemaining = 0,
    this.isProtectedFromAttack = false,
  });

  final int elapsedSeconds;
  final int remainingSeconds;

  // مكان الوحش، و null معناها إنه لسه مظهرش.
  final int? monsterRoom;

  // الكاميرا اللي اللاعب بيشوفها.
  final int selectedCameraRoom;

  // الوقت المتبقي قبل استخدام الصوت مرة أخرى.
  final int soundCooldownRemaining;

  // هل اللاعب محمي من الهجوم؟
  final bool isProtectedFromAttack;

  bool get hasMonsterAppeared => monsterRoom != null;

  bool get canUseSound => soundCooldownRemaining == 0;

  bool get isMonsterInSelectedRoom {
    return monsterRoom != null &&
        monsterRoom == selectedCameraRoom;
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

// اللاعب أنهى المرحلة بنجاح.
class SecondStageSuccess extends SecondStageState {
  const SecondStageSuccess();
}

// اللاعب خسر المرحلة.
class SecondStageFailure extends SecondStageState {
  const SecondStageFailure();
}