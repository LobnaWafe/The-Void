
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/core/utlis/assets_image.dart';
import 'package:the_void/features/game/domain/dialogue_option_entity.dart';
import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';
import 'package:the_void/features/game/presentation/widgets/type_writer_text.dart';

class GameChatViewBody extends StatefulWidget {
  const GameChatViewBody({super.key});

  @override
  State<GameChatViewBody> createState() => _GameChatViewBodyState();
}

class _GameChatViewBodyState extends State<GameChatViewBody> {
  String? _finishedDialogueKey;

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
          });
        }
      },
      builder: (context, state) {
        if (state is DialogueLoading || state is DialogueInitial) {
          return const Center(child: CircularProgressIndicator());
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
              child: Image.asset(AssetsImage.gameChatImage, fit: BoxFit.cover),
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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: TypewriterText(
                      key: ValueKey(currentDialogueKey),
                      text: dialogue.text[language] ?? '',
                      language: language,
                      onFinished: () {
                        if (!mounted) return;

                        setState(() {
                          _finishedDialogueKey = currentDialogueKey;
                        });
                      },
                    ),
                  ),

                  // Buttons appear below the dialogue bubble
                  if (isCurrentTextFinished) ...[
                    const SizedBox(height: 12),

                    if (dialogue.options.isNotEmpty)
                      ...dialogue.options.map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PlayerOptions(
                            option: option,
                            language: language,
                          ),
                        ),
                      )
                    else if (dialogue.nextId != null)
                      PlayerOptions(option: null, language: language),
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

class PlayerOptions extends StatelessWidget {
  final DialogueOptionEntity? option;
  final String language;

  const PlayerOptions({
    super.key,
    required this.option,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
  alignment: AlignmentDirectional.centerStart,
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25), // حواف دائرية للزرار
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.black.withOpacity(0.1), // الطرف الأيسر باهت تماماً
          Colors.black.withOpacity(0.8), // المنتصف واضح وقوي
          Colors.black.withOpacity(0.1), // الطرف الأيمن باهت تماماً
        ],
        // تحديد أماكن توزع الألوان بدقة (من الشمال لليمين)
        stops: const [0.0, 0.5, 1.0], 
      ),
    ),
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide.none,     
      ),
      onPressed: () {
        if (option != null) {
          context.read<DialogueCubit>().selectOption(option!);
        } else {
          context.read<DialogueCubit>().continueDialogue();
        }
      },
      child: Text(
        option?.text[language] ?? (language == 'ar' ? 'استمرار' : 'Continue'),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ),
);
  }
}


