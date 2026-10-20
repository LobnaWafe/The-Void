import 'package:the_void/core/helper/cach_helper.dart';

abstract class GameProgress {
  static const String _currentLocationKey = 'current_game_location';
  static const String _completedStageKey = 'completed_stage';

  // أماكن اللاعب في اللعبة
  static const String introduction = 'introduction';
  static const String firstStage = 'first_stage';
  static const String secondConversation = 'second_conversation';

  // لو دي أول مرة يلعب، يبدأ بالمقدمة.
  static String get currentLocation {
    return CacheHelper.getData(key: _currentLocationKey)
            as String? ??
        introduction;
  }

  // آخر لغز اكتمل بنجاح.
  static int get completedStage {
    return CacheHelper.getData(key: _completedStageKey)
            as int? ??
        0;
  }

  // حفظ المكان الحالي.
  static Future<void> setCurrentLocation(String location) async {
    await CacheHelper.saveData(
      key: _currentLocationKey,
      value: location,
    );
  }

  // حفظ اكتمال لغز والانتقال المنطقي التالي.
  static Future<void> completeStage({
    required int stage,
    required String nextLocation,
  }) async {
    if (stage > completedStage) {
      await CacheHelper.saveData(
        key: _completedStageKey,
        value: stage,
      );
    }

    await setCurrentLocation(nextLocation);
  }
}