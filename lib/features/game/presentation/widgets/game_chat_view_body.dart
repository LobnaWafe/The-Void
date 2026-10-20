import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/core/utlis/assets_image.dart';
import 'package:the_void/core/utlis/game_flow_manager.dart';
import 'package:the_void/core/utlis/milo_expressions.dart';
import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';
import 'package:the_void/features/game/presentation/widgets/options_list_widgets.dart';
import 'package:the_void/features/game/presentation/widgets/player_options.dart';
import 'package:the_void/features/game/presentation/widgets/type_writer_text.dart';

class GameChatViewBody extends StatefulWidget {
  const GameChatViewBody({super.key});

  @override
  State<GameChatViewBody> createState() => _GameChatViewBodyState();
}

class _GameChatViewBodyState extends State<GameChatViewBody> {
  String? _finishedDialogueKey;
  String? _handledActionDialogueId;

  // آخر تعبير ظهر لميلو.
  String _currentExpression = 'friendly';

  Future<void> _handleDialogueAction(String action) async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    await GameFlowManager.handleDialogueAction(context, action);
  }

  void _updateMiloExpression(String? expression) {
    // لو الحوار مفيهوش تعبير، نحتفظ بآخر صورة.
    if (expression == null) return;

    // التأكد إن التعبير موجود في الملف المركزي.
    if (!MiloExpressions.expressions.containsKey(expression)) {
      debugPrint('Unknown Milo expression: $expression');
      return;
    }

    // لو التعبير هو نفسه الحالي، مش محتاجين نغيّره.
    if (_currentExpression == expression) return;

    setState(() {
      _currentExpression = expression;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    return BlocConsumer<DialogueCubit, DialogueState>(
      listener: (context, state) {
        if (state is DialogueLoaded) {
          setState(() {
            _finishedDialogueKey = null;
            _handledActionDialogueId = null;
          });

          // تحديث تعبير ميلو لو الحوار الحالي يحتوي على expression.
          // لو مفيش expression، هيفضل على آخر تعبير.
          _updateMiloExpression(
            state.currentDialogue.expression,
          );
        }
      },
      builder: (context, state) {
        if (state is DialogueLoading || state is DialogueInitial) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is DialogueError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is! DialogueLoaded) {
          return const SizedBox.shrink();
        }

        final dialogue = state.currentDialogue;
        final language = state.language;
        final currentDialogueKey = '${dialogue.id}_$language';

        final isCurrentTextFinished =
            _finishedDialogueKey == currentDialogueKey;

        return Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                AssetsImage.gameChatImage,
                fit: BoxFit.cover,
              ),
            ),

            // Dialogue bubble and interaction area
            Positioned(
              top: height * 0.35,
              right: width * 0.25,
              left: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialogue bubble
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(4),
                        topRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: TypewriterText(
                      key: ValueKey(currentDialogueKey),
                      text: dialogue.text[language] ?? '',
                      language: language,
                      onFinished: () async {
                        if (!mounted) return;

                        setState(() {
                          _finishedDialogueKey = currentDialogueKey;
                        });

                        // تنفيذ الإجراء مرة واحدة فقط لكل حوار.
                        if (dialogue.action != null &&
                            _handledActionDialogueId != dialogue.id) {
                          _handledActionDialogueId = dialogue.id;

                          await _handleDialogueAction(
                            dialogue.action!,
                          );
                        }
                      },
                    ),
                  ),

                  // Options appear below the dialogue bubble.
                  if (isCurrentTextFinished) ...[
                    const SizedBox(height: 12),

                    if (dialogue.options.isNotEmpty)
                      OptionsListWidget(
                        height: height,
                        dialogue: dialogue,
                        language: language,
                      )
                    else if (dialogue.nextId != null)
                      PlayerOptions(
                        option: null,
                        language: language,
                      ),
                  ],
                ],
              ),
            ),

            // Milo
            Positioned(
              bottom: 0,
              right: 1,
              child: SizedBox(
                width: width * 0.35,
                child: Image.asset(
                  MiloExpressions.expressions[_currentExpression] ??
                      AssetsImage.miloFrame1Image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:the_void/core/utlis/assets_image.dart';
// import 'package:the_void/core/utlis/game_flow_manager.dart';
// import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';
// import 'package:the_void/features/game/presentation/widgets/options_list_widgets.dart';
// import 'package:the_void/features/game/presentation/widgets/player_options.dart';
// import 'package:the_void/features/game/presentation/widgets/type_writer_text.dart';

// class GameChatViewBody extends StatefulWidget {
//   const GameChatViewBody({super.key});

//   @override
//   State<GameChatViewBody> createState() => _GameChatViewBodyState();
// }

// class _GameChatViewBodyState extends State<GameChatViewBody> {
//   String? _finishedDialogueKey;
//   String? _handledActionDialogueId;

//   Future<void> _handleDialogueAction(String action) async {
//     Future.delayed(Duration(seconds: 2));

//     await GameFlowManager.handleDialogueAction(context, action);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//     final width = size.width;
//     final height = size.height;

//     return BlocConsumer<DialogueCubit, DialogueState>(
//       listener: (context, state) {
//         if (state is DialogueLoaded) {
//           setState(() {
//             _finishedDialogueKey = null;
//             _handledActionDialogueId = null;
//           });
//         }
//       },
//       builder: (context, state) {
//         if (state is DialogueLoading || state is DialogueInitial) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (state is DialogueError) {
//           return Center(
//             child: Text(
//               state.message,
//               style: const TextStyle(color: Colors.white),
//               textAlign: TextAlign.center,
//             ),
//           );
//         }

//         if (state is! DialogueLoaded) {
//           return const SizedBox.shrink();
//         }

//         final dialogue = state.currentDialogue;
//         final language = state.language;
//         final currentDialogueKey = '${dialogue.id}_$language';

//         final isCurrentTextFinished =
//             _finishedDialogueKey == currentDialogueKey;

//         return Stack(
//           children: [
//             // Background
//             Positioned.fill(
//               child: Image.asset(AssetsImage.gameChatImage, fit: BoxFit.cover),
//             ),

//             // Dialogue bubble and interaction area
//             Positioned(
//               top: height * 0.35,
//               right: width * 0.25,
//               left: 20,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Dialogue bubble
//                   Container(
//                     margin: const EdgeInsets.only(top: 10),
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.85),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(16),
//                         bottomLeft: Radius.circular(16),
//                         bottomRight: Radius.circular(4),
//                         topRight: Radius.circular(16),
//                       ),
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                     child: TypewriterText(
//                       key: ValueKey(currentDialogueKey),
//                       text: dialogue.text[language] ?? '',
//                       language: language,
//                       onFinished: () async {
//                         if (!mounted) return;

//                         setState(() {
//                           _finishedDialogueKey = currentDialogueKey;
//                         });

//                         // لو الحوار له إجراء، ننفذه مرة واحدة فقط.
//                         if (dialogue.action != null &&
//                             _handledActionDialogueId != dialogue.id) {
//                           _handledActionDialogueId = dialogue.id;

//                           await _handleDialogueAction(dialogue.action!);
//                         }
//                       },
//                     ),
//                   ),

//                   // Buttons appear below the dialogue bubble
//                   if (isCurrentTextFinished) ...[
//                     const SizedBox(height: 12),

//                     // if (dialogue.options.isNotEmpty)
//                     //   ...dialogue.options.map(
//                     //     (option) => Padding(
//                     //       padding: const EdgeInsets.only(bottom: 8),
//                     //       child: PlayerOptions(
//                     //         option: option,
//                     //         language: language,
//                     //       ),
//                     //     ),
//                     //   )
//                     if (dialogue.options.isNotEmpty)
//                       OptionsListWidget(height: height, dialogue: dialogue, language: language)
//                     else if (dialogue.nextId != null)
//                       PlayerOptions(option: null, language: language),
//                   ],
//                 ],
//               ),
//             ),

//             // Milo
//             Positioned(
//               bottom: 0,
//               right: 1,
//               child: SizedBox(
//                 width: width * 0.35,
//                 child: Image.asset(
//                   AssetsImage.miloFrame1Image,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
