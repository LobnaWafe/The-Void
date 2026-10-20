import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_void/core/utlis/app_router.dart';
import 'package:the_void/core/utlis/assets_path.dart';
import 'package:the_void/core/utlis/game_progress.dart';

class GameLocationConfig {
  final String route;
  final String? dialogueAssetPath;
  final String? initialDialogueId;

  const GameLocationConfig({
    required this.route,
    this.dialogueAssetPath,
    this.initialDialogueId,
  });
}

abstract class GameFlowManager {
  // Configuration for every game location.
  static final Map<String, GameLocationConfig> _locations = {
    GameProgress.introduction: GameLocationConfig(
      route: AppRouter.gameChatView,
      dialogueAssetPath: AssetsPath.introductionDialogue,
      initialDialogueId: 'opening_01',
    ),

    GameProgress.firstStage:  GameLocationConfig(
      route: AppRouter.firstStageView,
    ),

    GameProgress.secondConversation: GameLocationConfig(
      route: AppRouter.gameChatView,
      dialogueAssetPath: AssetsPath.secondConversationDialogue,
      initialDialogueId: 'second_01',
    ),
  };

  // Determines what should happen after each completed puzzle.
  static const Map<int, String> _nextLocationAfterStage = {
    1: GameProgress.secondConversation,
  };

  // Determines the destination for dialogue actions.
  static const Map<String, String> _dialogueActions = {
    'start_first_puzzle': GameProgress.firstStage,
  };

  // Get the configuration for the current location.
  static GameLocationConfig get currentLocationConfig {
    return _locations[GameProgress.currentLocation] ??
        _locations[GameProgress.introduction]!;
  }

  // Navigate to the correct location when starting or resuming the game.
  static void resumeGame(BuildContext context) {
    final config = currentLocationConfig;

    context.go(config.route);
  }

  // Handle actions attached to the end of a dialogue.
  static Future<void> handleDialogueAction(
    BuildContext context,
    String action,
  ) async {
    final destination = _dialogueActions[action];

    if (destination == null) {
      return;
    }

    await GameProgress.setCurrentLocation(destination);

    if (!context.mounted) return;

    final config = _locations[destination];

    if (config == null) {
      return;
    }

    context.go(config.route);
  }

  // Called when a puzzle has been completed successfully.
  static Future<void> completeStage(
    BuildContext context, {
    required int stage,
  }) async {
    final nextLocation = _nextLocationAfterStage[stage];

    if (nextLocation == null) {
      throw StateError(
        'No next location configured for completed stage $stage.',
      );
    }

    await GameProgress.completeStage(
      stage: stage,
      nextLocation: nextLocation,
    );

    if (!context.mounted) return;

    final config = _locations[nextLocation];

    if (config == null) {
      throw StateError(
        'No location configuration found for "$nextLocation".',
      );
    }

    context.go(config.route);
  }
}