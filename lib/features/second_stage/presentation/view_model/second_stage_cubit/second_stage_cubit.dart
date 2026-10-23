import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/features/second_stage/domain/monster_movement_manager.dart';

import 'second_stage_state.dart';

class SecondStageCubit extends Cubit<SecondStageState> {
  SecondStageCubit({
    MonsterMovementManager? monsterMovementManager,
    Random? random,
  })  : _monsterMovementManager =
            monsterMovementManager ?? MonsterMovementManager(),
        _random = random ?? Random(),
        super(const SecondStageInitial());

  final MonsterMovementManager _monsterMovementManager;

  final Random _random;

  Timer? _stageTimer;

  Timer? _movementTimer;

  Timer? _attackTimer;

  Timer? _attackWarningTimer;

  int _remainingSeconds = 180;

  int _elapsedSeconds = 0;

  int _selectedCameraRoom = 1;

  bool _hasFile = false;

  bool _isAttackStarted = false;

  bool _isMonsterAttacking = false;

  bool _isStageFinished = false;

  /// الوقت الذي قضاه الوحش في الغرفة الخامسة.
  int _roomFiveSeconds = 0;

  /// وقت الانتقال القادم للوحش.
  int _nextMovementDelay = 0;

  static const int stageDurationSeconds = 180;

  static const int monsterAppearanceDelaySeconds = 30;

  static const int attackWarningSeconds = 10;

  static const int attackFinalSeconds = 3;

  static const int totalAttackSeconds =
      attackWarningSeconds + attackFinalSeconds;

  int get remainingSeconds => _remainingSeconds;

  int get elapsedSeconds => _elapsedSeconds;

  int get monsterRoom => _monsterMovementManager.currentRoom;

  bool get hasFile => _hasFile;

  bool get isAttackStarted => _isAttackStarted;

  bool get isMonsterVisible => _monsterMovementManager.isVisible;

  /// بدء المرحلة.
  void startStage() {
    if (isClosed) {
      return;
    }

    _cancelTimers();

    _resetValues();

    _emitInProgress();

    _startStageTimer();

    _scheduleMonsterAppearance();
  }

  /// إعادة تشغيل المرحلة من البداية.
  ///
  /// تتم إعادة الطاقة من ViewBody،
  /// بينما يعيد هذا الـ Cubit ضبط الوقت والوحش والملف.
  void restartStage() {
    startStage();
  }

  void _resetValues() {
    _remainingSeconds = stageDurationSeconds;

    _elapsedSeconds = 0;

    _selectedCameraRoom = 1;

    _hasFile = false;

    _isAttackStarted = false;

    _isMonsterAttacking = false;

    _isStageFinished = false;

    _roomFiveSeconds = 0;

    _nextMovementDelay = 0;

    _monsterMovementManager.reset();
  }

  void _cancelTimers() {
    _stageTimer?.cancel();
    _stageTimer = null;

    _movementTimer?.cancel();
    _movementTimer = null;

    _attackTimer?.cancel();
    _attackTimer = null;

    _attackWarningTimer?.cancel();
    _attackWarningTimer = null;
  }

void _startStageTimer() {
  _stageTimer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      if (_isStageFinished || isClosed) {
        return;
      }

      _remainingSeconds--;
      _elapsedSeconds++;

      // إظهار الوحش بمجرد مرور أول 30 ثانية.
      if (_elapsedSeconds >= monsterAppearanceDelaySeconds &&
          !_monsterMovementManager.isVisible) {
        _monsterMovementManager.showMonster();
        _scheduleNextMonsterMovement();
      }

      if (_monsterMovementManager.isVisible &&
          _monsterMovementManager.currentRoom == 5) {
        _roomFiveSeconds++;
        _updateAttackState();
      }

      if (_isMonsterAttacking) {
        _finishStageAsFailure();
        return;
      }

      if (_remainingSeconds <= 0) {
        _handleStageTimeout();
        return;
      }

      _emitInProgress();
    },
  );
}

  /// الوحش يظل مختفيًا أول 30 ثانية.
  void _scheduleMonsterAppearance() {
    Future.delayed(
      const Duration(seconds: monsterAppearanceDelaySeconds),
      () {
        if (isClosed || _isStageFinished) {
          return;
        }

        if (_elapsedSeconds < monsterAppearanceDelaySeconds) {
          return;
        }

        _monsterMovementManager.showMonster();

        _scheduleNextMonsterMovement();

        _emitInProgress();
      },
    );
  }

  /// جدولة حركة الوحش التالية.
  void _scheduleNextMonsterMovement() {
    _movementTimer?.cancel();

    if (!_monsterMovementManager.isVisible ||
        _isStageFinished ||
        _monsterMovementManager.currentRoom == 5 ||
        _isAttackStarted) {
      return;
    }

    _nextMovementDelay =
        _monsterMovementManager.getNextMovementDelay();

    _movementTimer = Timer(
      Duration(seconds: _nextMovementDelay),
      () {
        if (isClosed || _isStageFinished) {
          return;
        }

        if (!_monsterMovementManager.isVisible) {
          return;
        }

        if (_monsterMovementManager.currentRoom == 5) {
          return;
        }

        final previousRoom =
            _monsterMovementManager.currentRoom;

        final newRoom =
            _monsterMovementManager.moveMonster();

        if (newRoom == 5 && previousRoom != 5) {
          _onMonsterEnteredRoomFive();
        } else {
          _emitInProgress();

          _scheduleNextMonsterMovement();
        }
      },
    );
  }

  /// عند دخول الغرفة الخامسة يبدأ عداد المواجهة.
  void _onMonsterEnteredRoomFive() {
    _movementTimer?.cancel();

    _roomFiveSeconds = 0;

    _isAttackStarted = false;

    _isMonsterAttacking = false;

    _attackWarningTimer?.cancel();

    _attackTimer?.cancel();

    _attackWarningTimer = Timer(
      const Duration(seconds: attackWarningSeconds),
      () {
        if (isClosed || _isStageFinished) {
          return;
        }

        if (_monsterMovementManager.currentRoom != 5) {
          return;
        }

        _isAttackStarted = true;

        _emitInProgress();

        _attackTimer = Timer(
          const Duration(seconds: attackFinalSeconds),
          () {
            if (isClosed || _isStageFinished) {
              return;
            }

            if (_monsterMovementManager.currentRoom != 5) {
              return;
            }

            _isMonsterAttacking = true;

            _finishStageAsFailure();
          },
        );
      },
    );

    _emitInProgress();
  }

  /// تحديث حالة المواجهة.
  ///
  /// يتم الاعتماد على Timer المواجهة،
  /// مع التحقق من أن الوحش لا يزال في الغرفة الخامسة.
  void _updateAttackState() {
    if (_monsterMovementManager.currentRoom != 5) {
      return;
    }

    if (_roomFiveSeconds >= attackWarningSeconds &&
        !_isAttackStarted) {
      _isAttackStarted = true;
    }

    if (_roomFiveSeconds >= totalAttackSeconds) {
      _isMonsterAttacking = true;
    }
  }

  /// استخدام الصوت.
  ///
  /// يعيد الوحش إلى الغرفة الأولى مباشرة،
  /// طالما لم يبدأ الهجوم النهائي.
  ///
  /// يجب على ViewBody منع الاستدعاء إذا كانت الطاقة صفرًا.
 bool activateSound() {
  if (isClosed || _isStageFinished) {
    return false;
  }

  // لا يمكن استخدام الصوت بعد بداية الهجوم النهائي.
  if (_isAttackStarted || _isMonsterAttacking) {
    return false;
  }

  // لو الوحش ظاهر، نوقف حركته ونرجعه للغرفة الأولى.
  if (_monsterMovementManager.isVisible) {
    _movementTimer?.cancel();
    _movementTimer = null;

    _attackWarningTimer?.cancel();
    _attackWarningTimer = null;

    _attackTimer?.cancel();
    _attackTimer = null;

    _monsterMovementManager.repelMonster();

    _roomFiveSeconds = 0;

    _isAttackStarted = false;
    _isMonsterAttacking = false;

    _emitInProgress();

    _scheduleNextMonsterMovement();
  }

  // الصوت مسموح حتى لو الوحش لسه مختفي.
  return true;
}
  /// اختيار غرفة من الكاميرات.
  ///
  /// اختيار الكاميرا لا يحرّك الوحش.
  void selectCameraRoom(int room) {
    if (isClosed || _isStageFinished) {
      return;
    }

    if (room < 1 || room > 5) {
      return;
    }

    _selectedCameraRoom = room;

    _emitInProgress();
  }

  /// الحصول على الملف من الكمبيوتر.
  void obtainFile() {
    if (isClosed || _isStageFinished || _hasFile) {
      return;
    }

    _hasFile = true;

    _emitInProgress();
  }

  void _handleStageTimeout() {
    if (_isStageFinished) {
      return;
    }

    _remainingSeconds = 0;

    if (_hasFile && !_isAttackStarted && !_isMonsterAttacking) {
      _finishStageAsSuccess();
    } else {
      _finishStageAsFailure();
    }
  }

  void _finishStageAsSuccess() {
    if (_isStageFinished || isClosed) {
      return;
    }

    _isStageFinished = true;

    _cancelTimers();

    emit(const SecondStageSuccess());
  }

  void _finishStageAsFailure() {
    if (_isStageFinished || isClosed) {
      return;
    }

    _isStageFinished = true;

    _cancelTimers();

    emit(const SecondStageFailure());
  }

  void _emitInProgress() {
    if (isClosed || _isStageFinished) {
      return;
    }

    emit(
      SecondStageInProgress(
        remainingSeconds: _remainingSeconds,
        elapsedSeconds: _elapsedSeconds,
        monsterRoom: _monsterMovementManager.currentRoom,
        isMonsterVisible: _monsterMovementManager.isVisible,
        selectedCameraRoom: _selectedCameraRoom,
        hasFile: _hasFile,
        isAttackStarted: _isAttackStarted,
        isMonsterAttacking: _isMonsterAttacking,
      ),
    );
  }

  @override
  Future<void> close() {
    _cancelTimers();

    return super.close();
  }
}

// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:the_void/features/second_stage/domain/monster_movement_manager.dart';
// import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_state.dart';

// class SecondStageCubit extends Cubit<SecondStageState> {
//   SecondStageCubit({
//     MonsterMovementManager? monsterMovementManager,
//   })  : _monsterManager =
//             monsterMovementManager ?? MonsterMovementManager(),
//         super(const SecondStageInitial());

//   final MonsterMovementManager _monsterManager;

//   Timer? _stageTimer;
//   Timer? _movementTimer;

//   static const int stageDurationSeconds = 180;

//   // يبدأ الهجوم بعد 10 ثوانٍ في الغرفة الخامسة.
//   static const int attackWarningSeconds = 10;

//   // ينتهي الهجوم بعد 13 ثانية من دخول الغرفة الخامسة.
//   static const int attackDurationSeconds = 13;

//   // اتركيها false في النسخة النهائية.
//   static const bool disableMonsterForTesting = false;

//   bool _started = false;

//   int _roomFiveSeconds = 0;

//   bool _attackStarted = false;

//   Duration get _elapsedTime {
//     final currentState = state;

//     if (currentState is SecondStageInProgress) {
//       return Duration(
//         seconds: currentState.elapsedSeconds,
//       );
//     }

//     return Duration.zero;
//   }

//   // =========================================================
//   // بدء المرحلة وإعادة تشغيلها
//   // =========================================================

//   void startStage() {
//     if (_started || isClosed) return;

//     _started = true;

//     _stopTimers();

//     _monsterManager.reset();

//     _roomFiveSeconds = 0;
//     _attackStarted = false;

//     emit(const SecondStageInProgress());

//     _stageTimer = Timer.periodic(
//       const Duration(seconds: 1),
//       (_) => _onStageTick(),
//     );
//   }

//   // إعادة ضبط المرحلة بعد الخسارة.
//   void restartStage() {
//     if (isClosed) return;

//     _stopTimers();

//     _started = false;

//     _monsterManager.reset();

//     _roomFiveSeconds = 0;
//     _attackStarted = false;

//     emit(const SecondStageInitial());

//     startStage();
//   }

//   // =========================================================
//   // عداد المرحلة
//   // =========================================================

//   void _onStageTick() {
//     if (isClosed || state is! SecondStageInProgress) {
//       return;
//     }

//     final currentState = state as SecondStageInProgress;

//     if (currentState.remainingSeconds <= 0) {
//       return;
//     }

//     final elapsedSeconds =
//         currentState.elapsedSeconds + 1;

//     final remainingSeconds =
//         stageDurationSeconds - elapsedSeconds;

//     final elapsedTime =
//         Duration(seconds: elapsedSeconds);

//     // انتهى الوقت.
//     if (remainingSeconds <= 0) {
//       _finishByTimer(currentState.hasFile);
//       return;
//     }

//     // تحديث الوقت مع الحفاظ على بيانات المرحلة.
//     emit(
//       SecondStageInProgress(
//         elapsedSeconds: elapsedSeconds,
//         remainingSeconds: remainingSeconds,
//         monsterRoom: currentState.monsterRoom,
//         selectedCameraRoom: currentState.selectedCameraRoom,
//         soundCooldownRemaining: _monsterManager
//             .getSoundCooldownRemaining(elapsedTime)
//             .inSeconds,
//         isProtectedFromAttack:
//             _monsterManager.isProtectedAt(elapsedTime),
//         isAttackStarted: _attackStarted,
//         attackSecondsRemaining:
//             _getAttackSecondsRemaining(),
//         hasFile: currentState.hasFile,
//       ),
//     );

//     // للاختبار فقط.
//     if (disableMonsterForTesting) {
//       return;
//     }

//     // ظهور الوحش بعد 30 ثانية.
//     if (!_monsterManager.hasAppeared &&
//         _monsterManager.canAppear(elapsedTime)) {
//       final room = _monsterManager.appear(elapsedTime);

//       _handleMonsterRoomChanged(room);

//       _emitCurrentGameState(
//         elapsedTime: elapsedTime,
//         monsterRoom: room,
//       );

//       debugPrint('ظهر الوحش في الغرفة $room');

//       // لو ظهر في الغرفة الخامسة، لا نبدأ مؤقت حركة آخر.
//       if (room != 5) {
//         _scheduleNextMovement();
//       }

//       return;
//     }

//     _updateAttack(elapsedTime);
//   }

//   // =========================================================
//   // الحصول على الملف
//   // =========================================================

//   void obtainFile() {
//     if (isClosed || state is! SecondStageInProgress) {
//       return;
//     }

//     final currentState = state as SecondStageInProgress;

//     if (currentState.hasFile) return;

//     emit(
//       SecondStageInProgress(
//         elapsedSeconds: currentState.elapsedSeconds,
//         remainingSeconds: currentState.remainingSeconds,
//         monsterRoom: currentState.monsterRoom,
//         selectedCameraRoom: currentState.selectedCameraRoom,
//         soundCooldownRemaining:
//             currentState.soundCooldownRemaining,
//         isProtectedFromAttack:
//             currentState.isProtectedFromAttack,
//         isAttackStarted: _attackStarted,
//         attackSecondsRemaining:
//             _getAttackSecondsRemaining(),
//         hasFile: true,
//       ),
//     );

//     debugPrint('اللاعب حصل على الملف');
//   }

//   // =========================================================
//   // الفوز أو الخسارة عند انتهاء الوقت
//   // =========================================================

//   void _finishByTimer(bool hasFile) {
//     if (isClosed || state is! SecondStageInProgress) {
//       return;
//     }

//     _stopTimers();

//     // لا يمكن الفوز إذا بدأ الهجوم بالفعل.
//     if (hasFile && !_attackStarted) {
//       emit(const SecondStageSuccess());

//       debugPrint(
//         'فاز اللاعب: الوقت انتهى والملف معه',
//       );
//     } else {
//       emit(const SecondStageFailure());

//       debugPrint(
//         'خسر اللاعب عند انتهاء الوقت',
//       );
//     }
//   }

//   // =========================================================
//   // هجوم الوحش
//   // =========================================================

//   int _getAttackSecondsRemaining() {
//     if (!_monsterManager.hasAppeared ||
//         _monsterManager.currentRoom != 5) {
//       return 0;
//     }

//     final remaining =
//         attackDurationSeconds - _roomFiveSeconds;

//     return remaining.clamp(0, attackDurationSeconds);
//   }

//   // استدعاء الدالة عند تغير غرفة الوحش.
//   void _handleMonsterRoomChanged(int? newRoom) {
//     _roomFiveSeconds = 0;
//     _attackStarted = false;

//     if (newRoom == 5) {
//       debugPrint('دخل الوحش الغرفة الخامسة');
//     }
//   }

//   void _updateAttack(Duration elapsedTime) {
//     if (!_monsterManager.hasAppeared ||
//         _monsterManager.currentRoom != 5) {
//       _roomFiveSeconds = 0;
//       _attackStarted = false;
//       return;
//     }

//     // الحماية تمنع بدء هجوم جديد.
//     if (!_attackStarted &&
//         _monsterManager.isProtectedAt(elapsedTime)) {
//       _roomFiveSeconds = 0;

//       _emitCurrentGameState(
//         elapsedTime: elapsedTime,
//       );

//       return;
//     }

//     _roomFiveSeconds++;

//     // يبدأ الهجوم بعد 10 ثوانٍ في الغرفة الخامسة.
//     if (_roomFiveSeconds >= attackWarningSeconds) {
//       _attackStarted = true;
//     }

//     // اكتمال الهجوم يعني الخسارة.
//     if (_roomFiveSeconds >= attackDurationSeconds) {
//       failStage();
//       return;
//     }

//     _emitCurrentGameState(
//       elapsedTime: elapsedTime,
//     );
//   }

//   // =========================================================
//   // تحديث حالة المرحلة
//   // =========================================================

//   void _emitCurrentGameState({
//     required Duration elapsedTime,
//     int? monsterRoom,
//   }) {
//     if (isClosed || state is! SecondStageInProgress) {
//       return;
//     }

//     final currentState = state as SecondStageInProgress;

//     emit(
//       SecondStageInProgress(
//         elapsedSeconds: currentState.elapsedSeconds,
//         remainingSeconds: currentState.remainingSeconds,
//         monsterRoom: monsterRoom ?? currentState.monsterRoom,
//         selectedCameraRoom: currentState.selectedCameraRoom,
//         soundCooldownRemaining: _monsterManager
//             .getSoundCooldownRemaining(elapsedTime)
//             .inSeconds,
//         isProtectedFromAttack:
//             _monsterManager.isProtectedAt(elapsedTime),
//         isAttackStarted: _attackStarted,
//         attackSecondsRemaining:
//             _getAttackSecondsRemaining(),
//         hasFile: currentState.hasFile,
//       ),
//     );
//   }

//   // =========================================================
//   // حركة الوحش
//   // =========================================================

//   void _scheduleNextMovement() {
//     _movementTimer?.cancel();

//     if (disableMonsterForTesting ||
//         isClosed ||
//         state is! SecondStageInProgress ||
//         !_monsterManager.hasAppeared) {
//       return;
//     }

//     // مهم: لا يتحرك الوحش أثناء وجوده في الغرفة الخامسة.
//     // نترك عداد الهجوم ينهي المواجهة.
//     if (_monsterManager.currentRoom == 5) {
//       return;
//     }

//     final currentState =
//         state as SecondStageInProgress;

//     if (currentState.remainingSeconds <= 0) {
//       return;
//     }

//     final delay =
//         _monsterManager.getNextMovementDelay();

//     _movementTimer = Timer(delay, () {
//       if (isClosed ||
//           state is! SecondStageInProgress ||
//           !_monsterManager.hasAppeared) {
//         return;
//       }

//       final latestState =
//           state as SecondStageInProgress;

//       if (latestState.remainingSeconds <= 0) {
//         return;
//       }

//       // احتياطًا: لا ننفذ الحركة أثناء الهجوم.
//       if (_attackStarted ||
//           _monsterManager.currentRoom == 5) {
//         return;
//       }

//       final newRoom =
//           _monsterManager.moveToNextRoom();

//       _handleMonsterRoomChanged(newRoom);

//       _emitCurrentGameState(
//         elapsedTime: _elapsedTime,
//         monsterRoom: newRoom,
//       );

//       debugPrint(
//         'انتقل الوحش إلى الغرفة $newRoom',
//       );

//       // لا نحدد حركة جديدة إذا دخل الغرفة الخامسة.
//       if (newRoom != 5) {
//         _scheduleNextMovement();
//       }
//     });
//   }

//   // =========================================================
//   // تغيير الكاميرا
//   // =========================================================

//   void selectCameraRoom(int roomNumber) {
//     if (isClosed ||
//         state is! SecondStageInProgress ||
//         roomNumber < 1 ||
//         roomNumber > 5) {
//       return;
//     }

//     final currentState =
//         state as SecondStageInProgress;

//     emit(
//       SecondStageInProgress(
//         elapsedSeconds: currentState.elapsedSeconds,
//         remainingSeconds: currentState.remainingSeconds,
//         monsterRoom: currentState.monsterRoom,
//         selectedCameraRoom: roomNumber,
//         soundCooldownRemaining:
//             currentState.soundCooldownRemaining,
//         isProtectedFromAttack:
//             currentState.isProtectedFromAttack,
//         isAttackStarted: _attackStarted,
//         attackSecondsRemaining:
//             _getAttackSecondsRemaining(),
//         hasFile: currentState.hasFile,
//       ),
//     );
//   }

//   // =========================================================
//   // صوت إبعاد الوحش
//   // =========================================================

//   bool activateSound() {
//     if (disableMonsterForTesting ||
//         isClosed ||
//         state is! SecondStageInProgress) {
//       return false;
//     }

//     final currentState =
//         state as SecondStageInProgress;

//     if (currentState.remainingSeconds <= 0 ||
//         !_monsterManager.hasAppeared) {
//       return false;
//     }

//     final elapsedTime = _elapsedTime;

//     final success = _monsterManager.activateSound(
//       elapsedTime: elapsedTime,
//       attackStarted: _attackStarted,
//     );

//     if (!success) return false;

//     // لو الهجوم لم يبدأ، يتم إبعاد الوحش.
//     if (!_attackStarted) {
//       _handleMonsterRoomChanged(
//         _monsterManager.currentRoom,
//       );
//     }

//     _emitCurrentGameState(
//       elapsedTime: elapsedTime,
//       monsterRoom: _monsterManager.currentRoom,
//     );

//     // لو الهجوم بدأ، لا نلغي الهجوم ولا نغير الغرفة.
//     if (!_attackStarted) {
//       _scheduleNextMovement();
//     }

//     debugPrint('تم استخدام صوت إبعاد الوحش');

//     return true;
//   }

//   // =========================================================
//   // إنهاء المرحلة
//   // =========================================================

//   void completeStage() {
//     if (isClosed || state is! SecondStageInProgress) {
//       return;
//     }

//     final currentState =
//         state as SecondStageInProgress;

//     _finishByTimer(currentState.hasFile);
//   }

//   void failStage() {
//     if (isClosed || state is! SecondStageInProgress) {
//       return;
//     }

//     _stopTimers();

//     debugPrint('خسر اللاعب بسبب هجوم الوحش');

//     emit(const SecondStageFailure());
//   }

//   void _stopTimers() {
//     _stageTimer?.cancel();
//     _movementTimer?.cancel();

//     _stageTimer = null;
//     _movementTimer = null;
//   }

//   @override
//   Future<void> close() {
//     _stopTimers();

//     return super.close();
//   }
// }

// // import 'dart:async';

// // import 'package:flutter/foundation.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';

// // import 'package:the_void/features/second_stage/domain/monster_movement_manager.dart';
// // import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_state.dart';

// // class SecondStageCubit extends Cubit<SecondStageState> {
// //   SecondStageCubit({
// //     MonsterMovementManager? monsterMovementManager,
// //   })  : _monsterManager =
// //             monsterMovementManager ?? MonsterMovementManager(),
// //         super(const SecondStageInitial());

// //   final MonsterMovementManager _monsterManager;

// //   Timer? _stageTimer;
// //   Timer? _movementTimer;

// //   static const int stageDurationSeconds = 180;

// //   static const int attackWarningSeconds = 10;
// //   static const int attackDurationSeconds = 13;

// //   // true = تعطيل الوحش للاختبار.
// //   // بعد الانتهاء من الاختبار غيّريها إلى false.
// //   static const bool disableMonsterForTesting = false;

// //   bool _started = false;
// //   int _roomFiveSeconds = 0;
// //   bool _attackStarted = false;

// //   Duration get _elapsedTime {
// //     if (state is SecondStageInProgress) {
// //       return Duration(
// //         seconds: (state as SecondStageInProgress).elapsedSeconds,
// //       );
// //     }

// //     return Duration.zero;
// //   }

// //   // بدء المرحلة.
// //   void startStage() {
// //     if (_started || isClosed) return;

// //     _started = true;

// //     _monsterManager.reset();
// //     _roomFiveSeconds = 0;
// //     _attackStarted = false;

// //     emit(const SecondStageInProgress());

// //     _stageTimer = Timer.periodic(
// //       const Duration(seconds: 1),
// //       (_) => _onStageTick(),
// //     );
// //   }

// //   // تحديث العداد كل ثانية.
// //   void _onStageTick() {
// //     if (isClosed || state is! SecondStageInProgress) {
// //       return;
// //     }

// //     final currentState = state as SecondStageInProgress;

// //     if (currentState.remainingSeconds <= 0) {
// //       return;
// //     }

// //     final elapsedSeconds = currentState.elapsedSeconds + 1;

// //     final remainingSeconds =
// //         stageDurationSeconds - elapsedSeconds;

// //     final elapsedTime = Duration(seconds: elapsedSeconds);

// //     // انتهى الوقت: الملف يحدد الفوز أو الخسارة.
// //     if (remainingSeconds <= 0) {
// //       _finishByTimer(currentState.hasFile);
// //       return;
// //     }

// //     // تحديث الوقت مع الاحتفاظ بحالة الملف.
// //     emit(
// //       SecondStageInProgress(
// //         elapsedSeconds: elapsedSeconds,
// //         remainingSeconds: remainingSeconds,
// //         monsterRoom: currentState.monsterRoom,
// //         selectedCameraRoom: currentState.selectedCameraRoom,
// //         soundCooldownRemaining: _monsterManager
// //             .getSoundCooldownRemaining(elapsedTime)
// //             .inSeconds,
// //         isProtectedFromAttack:
// //             _monsterManager.isProtectedAt(elapsedTime),
// //         isAttackStarted: _attackStarted,
// //         attackSecondsRemaining: _getAttackSecondsRemaining(),
// //         hasFile: currentState.hasFile,
// //       ),
// //     );

// //     // أثناء الاختبار، الوقت مستمر لكن الوحش متوقف تمامًا.
// //     if (disableMonsterForTesting) {
// //       return;
// //     }

// //     // ظهور الوحش بعد 30 ثانية.
// //     if (!_monsterManager.hasAppeared &&
// //         _monsterManager.canAppear(elapsedTime)) {
// //       final room = _monsterManager.appear(elapsedTime);

// //       _handleMonsterRoomChanged(room);

// //       _emitCurrentGameState(
// //         elapsedTime: elapsedTime,
// //         monsterRoom: room,
// //       );

// //       debugPrint('ظهر الوحش في الغرفة $room');

// //       _scheduleNextMovement();
// //       return;
// //     }

// //     _updateAttack(elapsedTime);
// //   }

// //   // تسجيل حصول اللاعب على الملف.
// //   void obtainFile() {
// //     if (isClosed || state is! SecondStageInProgress) {
// //       return;
// //     }

// //     final currentState = state as SecondStageInProgress;

// //     if (currentState.hasFile) return;

// //     emit(
// //       SecondStageInProgress(
// //         elapsedSeconds: currentState.elapsedSeconds,
// //         remainingSeconds: currentState.remainingSeconds,
// //         monsterRoom: currentState.monsterRoom,
// //         selectedCameraRoom: currentState.selectedCameraRoom,
// //         soundCooldownRemaining:
// //             currentState.soundCooldownRemaining,
// //         isProtectedFromAttack:
// //             currentState.isProtectedFromAttack,
// //         isAttackStarted: _attackStarted,
// //         attackSecondsRemaining: _getAttackSecondsRemaining(),
// //         hasFile: true,
// //       ),
// //     );

// //     debugPrint('اللاعب حصل على الملف');
// //   }

// //   // انتهاء الوقت يحدد النتيجة حسب امتلاك الملف.
// //   void _finishByTimer(bool hasFile) {
// //     if (isClosed || state is! SecondStageInProgress) {
// //       return;
// //     }

// //     _stopTimers();

// //     if (hasFile) {
// //       emit(const SecondStageSuccess());
// //       debugPrint('فاز اللاعب: الوقت انتهى والملف معه');
// //     } else {
// //       emit(const SecondStageFailure());
// //       debugPrint('خسر اللاعب: الوقت انتهى والملف ليس معه');
// //     }
// //   }

// //   // حساب الوقت المتبقي للهجوم.
// //   int _getAttackSecondsRemaining() {
// //     if (!_monsterManager.hasAppeared ||
// //         _monsterManager.currentRoom != 5) {
// //       return 0;
// //     }

// //     final remaining = attackDurationSeconds - _roomFiveSeconds;

// //     return remaining.clamp(0, attackDurationSeconds);
// //   }

// //   // التعامل مع دخول غرفة جديدة.
// //   void _handleMonsterRoomChanged(int? newRoom) {
// //     _roomFiveSeconds = 0;
// //     _attackStarted = false;

// //     if (newRoom == 5) {
// //       debugPrint('دخل الوحش الغرفة الخامسة');
// //     }
// //   }

// //   // متابعة عداد الهجوم.
// //   void _updateAttack(Duration elapsedTime) {
// //     if (!_monsterManager.hasAppeared ||
// //         _monsterManager.currentRoom != 5) {
// //       _roomFiveSeconds = 0;
// //       _attackStarted = false;
// //       return;
// //     }

// //     // الحماية تمنع بدء هجوم جديد.
// //     if (!_attackStarted &&
// //         _monsterManager.isProtectedAt(elapsedTime)) {
// //       _roomFiveSeconds = 0;
// //       return;
// //     }

// //     _roomFiveSeconds++;

// //     // يبدأ الهجوم بعد 10 ثوانٍ في الغرفة الخامسة.
// //     if (_roomFiveSeconds >= attackWarningSeconds) {
// //       _attackStarted = true;
// //     }

// //     // اكتمال الهجوم يعني الخسارة في كل الحالات.
// //     if (_roomFiveSeconds >= attackDurationSeconds) {
// //       failStage();
// //       return;
// //     }

// //     _emitCurrentGameState(elapsedTime: elapsedTime);
// //   }

// //   // تحديث الحالة مع الاحتفاظ ببيانات اللعب.
// //   void _emitCurrentGameState({
// //     required Duration elapsedTime,
// //     int? monsterRoom,
// //   }) {
// //     if (isClosed || state is! SecondStageInProgress) {
// //       return;
// //     }

// //     final currentState = state as SecondStageInProgress;

// //     emit(
// //       SecondStageInProgress(
// //         elapsedSeconds: currentState.elapsedSeconds,
// //         remainingSeconds: currentState.remainingSeconds,
// //         monsterRoom: monsterRoom ?? currentState.monsterRoom,
// //         selectedCameraRoom: currentState.selectedCameraRoom,
// //         soundCooldownRemaining: _monsterManager
// //             .getSoundCooldownRemaining(elapsedTime)
// //             .inSeconds,
// //         isProtectedFromAttack:
// //             _monsterManager.isProtectedAt(elapsedTime),
// //         isAttackStarted: _attackStarted,
// //         attackSecondsRemaining: _getAttackSecondsRemaining(),
// //         hasFile: currentState.hasFile,
// //       ),
// //     );
// //   }

// //   // جدولة حركة الوحش التالية.
// //   void _scheduleNextMovement() {
// //     _movementTimer?.cancel();

// //     if (disableMonsterForTesting ||
// //         isClosed ||
// //         state is! SecondStageInProgress ||
// //         !_monsterManager.hasAppeared) {
// //       return;
// //     }

// //     final currentState = state as SecondStageInProgress;

// //     if (currentState.remainingSeconds <= 0) {
// //       return;
// //     }

// //     final delay = _monsterManager.getNextMovementDelay();

// //     _movementTimer = Timer(delay, () {
// //       if (isClosed ||
// //           state is! SecondStageInProgress ||
// //           !_monsterManager.hasAppeared) {
// //         return;
// //       }

// //       final latestState = state as SecondStageInProgress;

// //       if (latestState.remainingSeconds <= 0) {
// //         return;
// //       }

// //       final newRoom = _monsterManager.moveToNextRoom();

// //       _handleMonsterRoomChanged(newRoom);

// //       _emitCurrentGameState(
// //         elapsedTime: _elapsedTime,
// //         monsterRoom: newRoom,
// //       );

// //       debugPrint('انتقل الوحش إلى الغرفة $newRoom');

// //       _scheduleNextMovement();
// //     });
// //   }

// //   // تغيير الكاميرا.
// //   void selectCameraRoom(int roomNumber) {
// //     if (isClosed ||
// //         state is! SecondStageInProgress ||
// //         roomNumber < 1 ||
// //         roomNumber > 5) {
// //       return;
// //     }

// //     final currentState = state as SecondStageInProgress;

// //     emit(
// //       SecondStageInProgress(
// //         elapsedSeconds: currentState.elapsedSeconds,
// //         remainingSeconds: currentState.remainingSeconds,
// //         monsterRoom: currentState.monsterRoom,
// //         selectedCameraRoom: roomNumber,
// //         soundCooldownRemaining:
// //             currentState.soundCooldownRemaining,
// //         isProtectedFromAttack:
// //             currentState.isProtectedFromAttack,
// //         isAttackStarted: _attackStarted,
// //         attackSecondsRemaining: _getAttackSecondsRemaining(),
// //         hasFile: currentState.hasFile,
// //       ),
// //     );
// //   }

// //   // تشغيل صوت إبعاد الوحش.
// //   bool activateSound() {
// //     if (disableMonsterForTesting ||
// //         isClosed ||
// //         state is! SecondStageInProgress) {
// //       return false;
// //     }

// //     final currentState = state as SecondStageInProgress;

// //     if (currentState.remainingSeconds <= 0 ||
// //         !_monsterManager.hasAppeared) {
// //       return false;
// //     }

// //     final elapsedTime = _elapsedTime;

// //     final success = _monsterManager.activateSound(
// //       elapsedTime: elapsedTime,
// //       attackStarted: _attackStarted,
// //     );

// //     if (!success) return false;

// //     _playSoundEffect();

// //     if (!_attackStarted) {
// //       _handleMonsterRoomChanged(_monsterManager.currentRoom);
// //     }

// //     _emitCurrentGameState(
// //       elapsedTime: elapsedTime,
// //       monsterRoom: _monsterManager.currentRoom,
// //     );

// //     _scheduleNextMovement();

// //     debugPrint('تم تشغيل الصوت');

// //     return true;
// //   }

// //   // مكان ربط ملف الصوت لاحقًا.
// //   void _playSoundEffect() {
// //     // TODO: استدعاء AudioPlayer.
// //     // مثال: assets/audios/security_sound.mp3
// //   }

// //   // إنهاء المرحلة بنجاح عند الحاجة.
// //   // في الاستخدام الطبيعي، النتيجة يحددها انتهاء الوقت.
// //   void completeStage() {
// //     if (isClosed || state is! SecondStageInProgress) {
// //       return;
// //     }

// //     final currentState = state as SecondStageInProgress;
// //     _finishByTimer(currentState.hasFile);
// //   }

// //   // الخسارة عند اكتمال هجوم الوحش.
// //   void failStage() {
// //     if (isClosed || state is! SecondStageInProgress) {
// //       return;
// //     }

// //     _stopTimers();
// //      debugPrint('خسر اللاعب بسبب هجوم الوحش');
// //     emit(const SecondStageFailure());

// // //    debugPrint('خسر اللاعب بسبب هجوم الوحش');
// //   }

// //   void _stopTimers() {
// //     _stageTimer?.cancel();
// //     _movementTimer?.cancel();

// //     _stageTimer = null;
// //     _movementTimer = null;
// //   }

// //   @override
// //   Future<void> close() {
// //     _stopTimers();
// //     return super.close();
// //   }
// // }

