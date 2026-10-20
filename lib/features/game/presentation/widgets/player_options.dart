
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/features/game/domain/dialogue_option_entity.dart';
import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';

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
          style: OutlinedButton.styleFrom(side: BorderSide.none),
          onPressed: () {
            if (option != null) {
              context.read<DialogueCubit>().selectOption(option!);
            } else {
              context.read<DialogueCubit>().continueDialogue();
            }
          },
          child: Text(
            option?.text[language] ??
                (language == 'ar' ? 'استمرار' : 'Continue'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
