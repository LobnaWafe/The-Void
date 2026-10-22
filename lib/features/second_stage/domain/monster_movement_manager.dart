import 'dart:math';

class MonsterMovementManager {
  MonsterMovementManager({
    Random? random,
    this.initialDelay = const Duration(seconds: 30),
    this.minMovementDelay = const Duration(seconds: 5),
    this.maxMovementDelay = const Duration(seconds: 12),
    this.soundCooldown = const Duration(seconds: 20),
    this.soundProtectionDuration = const Duration(seconds: 25),
  }) : _random = random ?? Random();

  final Random _random;

  // وقت ظهور الوحش.
  final Duration initialDelay;

  // مدة الانتظار بين الحركات.
  final Duration minMovementDelay;
  final Duration maxMovementDelay;

  // إعدادات الصوت.
  final Duration soundCooldown;
  final Duration soundProtectionDuration;

  int? _currentRoom;

  Duration? _lastSoundTime;
  Duration? _protectionStartTime;

  int? get currentRoom => _currentRoom;

  bool get hasAppeared => _currentRoom != null;

  // هل مر وقت ظهور الوحش؟
  bool canAppear(Duration elapsedTime) {
    return elapsedTime >= initialDelay;
  }

  // إظهار الوحش في غرفة من 1 إلى 4.
  int appear(Duration elapsedTime) {
    if (!canAppear(elapsedTime)) {
      throw StateError(
        'The monster cannot appear before the initial delay.',
      );
    }

    _currentRoom ??= _random.nextInt(4) + 1;

    return _currentRoom!;
  }

  // الغرف المتصلة بالغرفة الحالية.
  List<int> _getPossibleRooms() {
    switch (_currentRoom) {
      case 1:
        return [2, 3];

      case 2:
        return [1, 3];

      case 3:
        return [1, 2, 4];

      case 4:
        return [2, 3, 5];

      case 5:
        return [4];

      default:
        return [];
    }
  }

  // الانتقال إلى غرفة متصلة.
  int moveToNextRoom() {
    if (_currentRoom == null) {
      throw StateError(
        'The monster has not appeared yet.',
      );
    }

    final possibleRooms = _getPossibleRooms();

    if (possibleRooms.isEmpty) {
      throw StateError(
        'No valid room is available.',
      );
    }

    _currentRoom =
        possibleRooms[_random.nextInt(possibleRooms.length)];

    return _currentRoom!;
  }

  // اختيار مدة عشوائية للحركة التالية.
  Duration getNextMovementDelay() {
    final minMs = minMovementDelay.inMilliseconds;
    final maxMs = maxMovementDelay.inMilliseconds;

    if (minMs < 0 || maxMs < minMs) {
      throw ArgumentError(
        'Movement delay range is invalid.',
      );
    }

    final difference = maxMs - minMs;

    final delayMs = minMs +
        (difference == 0
            ? 0
            : _random.nextInt(difference + 1));

    return Duration(milliseconds: delayMs);
  }

  // هل يمكن استخدام الصوت؟
  bool canUseSoundAt(Duration elapsedTime) {
    if (_lastSoundTime == null) {
      return true;
    }

    return elapsedTime - _lastSoundTime! >= soundCooldown;
  }

  // الوقت المتبقي قبل استخدام الصوت مجددًا.
  Duration getSoundCooldownRemaining(Duration elapsedTime) {
    if (_lastSoundTime == null) {
      return Duration.zero;
    }

    final elapsedSinceSound =
        elapsedTime - _lastSoundTime!;

    final remaining = soundCooldown - elapsedSinceSound;

    if (remaining.isNegative) {
      return Duration.zero;
    }

    return remaining;
  }

  // هل الحماية من الهجمات الجديدة فعالة؟
  bool isProtectedAt(Duration elapsedTime) {
    if (_protectionStartTime == null) {
      return false;
    }

    return elapsedTime - _protectionStartTime! <
        soundProtectionDuration;
  }

  // تسجيل استخدام الصوت.
  //
  // الصوت متاح فقط إذا انتهت فترة الانتظار.
  // لو بدأ الهجوم بالفعل، لا يغيّر الصوت مكان الوحش
  // ولا يلغي الهجوم الجاري.
  //
  // attackStarted هنا يحدد هل الهجوم بدأ قبل استخدام الصوت.
bool activateSound({
  required Duration elapsedTime,
  required bool attackStarted,
}) {
  if (!canUseSoundAt(elapsedTime)) return false;

  _lastSoundTime = elapsedTime;

  if (attackStarted) return true;

  _protectionStartTime = elapsedTime;
  _currentRoom = 1;

  return true;
}

  // إعادة ضبط بيانات الوحش.
  void reset() {
    _currentRoom = null;
    _lastSoundTime = null;
    _protectionStartTime = null;
  }
}

// import 'dart:math';

// class MonsterMovementManager {
//   MonsterMovementManager({
//     Random? random,
//     this.initialDelay = const Duration(seconds: 30),
//     this.minMovementDelay = const Duration(seconds: 5),
//     this.maxMovementDelay = const Duration(seconds: 12),
//     this.soundCooldown = const Duration(seconds: 20),
//     this.soundProtectionDuration = const Duration(seconds: 25),
//   }) : _random = random ?? Random();

//   final Random _random;

//   // مدة الانتظار قبل ظهور الوحش.
//   final Duration initialDelay;

//   // المدة العشوائية بين انتقالات الوحش.
//   final Duration minMovementDelay;
//   final Duration maxMovementDelay;

//   // إعدادات الصوت.
//   final Duration soundCooldown;
//   final Duration soundProtectionDuration;

//   int? _currentRoom;

//   Duration? _lastSoundTime;
//   Duration? _protectionStartTime;

//   int? get currentRoom => _currentRoom;

//   bool get hasAppeared => _currentRoom != null;

//   // هل مر الوقت المطلوب لظهور الوحش؟
//   bool canAppear(Duration elapsedTime) {
//     return elapsedTime >= initialDelay;
//   }

//   // إظهار الوحش لأول مرة.
//   // يبدأ في الغرف من 1 إلى 4 فقط.
//   int appear(Duration elapsedTime) {
//     if (!canAppear(elapsedTime)) {
//       throw StateError(
//         'The monster cannot appear before 30 seconds.',
//       );
//     }

//     _currentRoom ??= _random.nextInt(4) + 1;

//     return _currentRoom!;
//   }

//   // الغرف التي يمكن الانتقال إليها من الغرفة الحالية.
//   List<int> _getPossibleRooms() {
//     switch (_currentRoom) {
//       case 1:
//         return [2, 3];

//       case 2:
//         return [1, 3];

//       case 3:
//         return [1, 2, 4];

//       case 4:
//         return [2, 3, 5];

//       case 5:
//         return [4];

//       default:
//         return [];
//     }
//   }

//   // الانتقال إلى غرفة جديدة.
//   int moveToNextRoom() {
//     if (_currentRoom == null) {
//       throw StateError(
//         'The monster has not appeared yet.',
//       );
//     }

//     final possibleRooms = _getPossibleRooms();

//     if (possibleRooms.isEmpty) {
//       throw StateError(
//         'No valid room is available.',
//       );
//     }

//     _currentRoom =
//         possibleRooms[_random.nextInt(possibleRooms.length)];

//     return _currentRoom!;
//   }

//   // اختيار مدة عشوائية للحركة التالية.
//   Duration getNextMovementDelay() {
//     final minMs = minMovementDelay.inMilliseconds;
//     final maxMs = maxMovementDelay.inMilliseconds;

//     if (minMs < 0 || maxMs < minMs) {
//       throw ArgumentError(
//         'Movement delay range is invalid.',
//       );
//     }

//     final difference = maxMs - minMs;

//     final delayMs = minMs +
//         (difference == 0
//             ? 0
//             : _random.nextInt(difference + 1));

//     return Duration(milliseconds: delayMs);
//   }

//   // التحقق من إمكانية استخدام الصوت.
//   bool canUseSoundAt(Duration elapsedTime) {
//     if (_lastSoundTime == null) {
//       return true;
//     }

//     return elapsedTime - _lastSoundTime! >= soundCooldown;
//   }

//   // الوقت المتبقي قبل السماح باستخدام الصوت مجددًا.
//   Duration getSoundCooldownRemaining(Duration elapsedTime) {
//     if (_lastSoundTime == null) {
//       return Duration.zero;
//     }

//     final elapsedSinceSound = elapsedTime - _lastSoundTime!;

//     final remaining = soundCooldown - elapsedSinceSound;

//     if (remaining.isNegative) {
//       return Duration.zero;
//     }

//     return remaining;
//   }

//   // هل الحماية من الهجوم ما زالت فعالة؟
//   bool isProtectedAt(Duration elapsedTime) {
//     if (_protectionStartTime == null) {
//       return false;
//     }

//     return elapsedTime - _protectionStartTime! <
//         soundProtectionDuration;
//   }

//   // تشغيل الصوت وإرجاع الوحش خطوة واحدة.
//   bool activateSound({
//     required Duration elapsedTime,
//     required bool attackStarted,
//   }) {
//     if (!hasAppeared) {
//       return false;
//     }

//     if (!canUseSoundAt(elapsedTime)) {
//       return false;
//     }

//     // الصوت لا يلغي هجومًا بدأ بالفعل.
//     if (attackStarted) {
//       return false;
//     }

//     _lastSoundTime = elapsedTime;
//     _protectionStartTime = elapsedTime;

//     // التراجع خطوة واحدة.
//     switch (_currentRoom) {
//       case 5:
//         _currentRoom = 4;
//         break;

//       case 4:
//         _currentRoom = 3;
//         break;

//       case 3:
//         _currentRoom = 2;
//         break;

//       case 2:
//         _currentRoom = 1;
//         break;

//       case 1:
//         // لا توجد غرفة أسبق من الغرفة الأولى.
//         break;
//     }

//     return true;
//   }

//   // إعادة ضبط بيانات الوحش عند إعادة المرحلة.
//   void reset() {
//     _currentRoom = null;
//     _lastSoundTime = null;
//     _protectionStartTime = null;
//   }
// }