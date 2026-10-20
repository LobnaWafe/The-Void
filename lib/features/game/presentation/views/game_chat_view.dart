import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/core/utlis/game_flow_manager.dart';
import 'package:the_void/core/utlis/get_it.dart';
import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';
import 'package:the_void/features/game/presentation/widgets/game_chat_view_body.dart';

class GameChatView extends StatelessWidget {
  const GameChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final config = GameFlowManager.currentLocationConfig;

    final assetPath = config.dialogueAssetPath;
    final initialDialogueId = config.initialDialogueId;

    if (assetPath == null || initialDialogueId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No dialogue configured for this location.'),
        ),
      );
    }

    return BlocProvider(
      create: (context) => getIt<DialogueCubit>()
        ..loadDialogues(
          assetPath: assetPath,
          initialDialogueId: initialDialogueId,
        ),
      child: const Scaffold(
        body: GameChatViewBody(),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:the_void/core/utlis/get_it.dart';
// import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';
// import 'package:the_void/features/game/presentation/widgets/game_chat_view_body.dart';

// class GameChatView extends StatelessWidget {
//   const GameChatView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<DialogueCubit>()..loadDialogues(),
//       child: Scaffold(body: GameChatViewBody()),
//     );
//   }
// }
