import 'package:flutter/foundation.dart';

@immutable
abstract class SecondStageState {
  const SecondStageState();
}

// الحالة الأولية.
class SecondStageInitial extends SecondStageState {
  const SecondStageInitial();
}

// المرحلة أثناء اللعب.
class SecondStageInProgress extends SecondStageState {
  const SecondStageInProgress({
    this.elapsedSeconds = 0,
    this.remainingSeconds = 180,
    this.monsterRoom,
    this.selectedCameraRoom = 1,
    this.soundCooldownRemaining = 0,
    this.isProtectedFromAttack = false,
    this.isAttackStarted = false,
    this.attackSecondsRemaining = 0,
    this.hasFile = false,
  });

  final int elapsedSeconds;
  final int remainingSeconds;
  final int? monsterRoom;
  final int selectedCameraRoom;
  final int soundCooldownRemaining;
  final bool isProtectedFromAttack;
  final bool isAttackStarted;
  final int attackSecondsRemaining;

  // هل حصل اللاعب على الملف؟
  final bool hasFile;

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

  String get formattedAttackTime {
    return attackSecondsRemaining.toString().padLeft(2, '0');
  }
}

// الفوز بالمرحلة.
class SecondStageSuccess extends SecondStageState {
  const SecondStageSuccess();
}

// الخسارة في المرحلة.
class SecondStageFailure extends SecondStageState {
  const SecondStageFailure();
}

// import 'package:flutter/foundation.dart';

// @immutable
// abstract class SecondStageState {
//   const SecondStageState();
// }

// // الحالة الأولية قبل بداية المرحلة.
// class SecondStageInitial extends SecondStageState {
//   const SecondStageInitial();
// }

// // الحالة أثناء اللعب.
// class SecondStageInProgress extends SecondStageState {
//   const SecondStageInProgress({
//     this.elapsedSeconds = 0,
//     this.remainingSeconds = 180,
//     this.monsterRoom,
//     this.selectedCameraRoom = 1,
//     this.soundCooldownRemaining = 0,
//     this.isProtectedFromAttack = false,
//   });

//   final int elapsedSeconds;
//   final int remainingSeconds;

//   // مكان الوحش، و null معناها إنه لسه مظهرش.
//   final int? monsterRoom;

//   // الكاميرا اللي اللاعب بيشوفها.
//   final int selectedCameraRoom;

//   // الوقت المتبقي قبل استخدام الصوت مرة أخرى.
//   final int soundCooldownRemaining;

//   // هل اللاعب محمي من الهجوم؟
//   final bool isProtectedFromAttack;

//   bool get hasMonsterAppeared => monsterRoom != null;

//   bool get canUseSound => soundCooldownRemaining == 0;

//   bool get isMonsterInSelectedRoom {
//     return monsterRoom != null &&
//         monsterRoom == selectedCameraRoom;
//   }

//   String get formattedTime {
//     final minutes = remainingSeconds ~/ 60;
//     final seconds = remainingSeconds % 60;

//     return '${minutes.toString().padLeft(2, '0')}:'
//         '${seconds.toString().padLeft(2, '0')}';
//   }
// }

// // اللاعب أنهى المرحلة بنجاح.
// class SecondStageSuccess extends SecondStageState {
//   const SecondStageSuccess();
// }

// // اللاعب خسر المرحلة.
// class SecondStageFailure extends SecondStageState {
//   const SecondStageFailure();
// }