import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/core/utlis/assets_path.dart';
import 'package:the_void/features/game/domain/dialogue_entity.dart';
import 'package:the_void/features/game/domain/dialogue_option_entity.dart';
import 'package:the_void/features/game/domain/repos/dialog_repo.dart';

part 'dialogue_state.dart';

class DialogueCubit extends Cubit<DialogueState> {
  final DialogueRepo dialogueRepo;

  String _language = 'en';

  DialogueCubit(this.dialogueRepo) : super(DialogueInitial());

  Future<void> loadDialogues({
    String assetPath = AssetsPath.introductionDialogue,
    String initialDialogueId = 'opening_01',
  }) async {
    emit(DialogueLoading());

    final result = await dialogueRepo.loadDialogues(
      assetPath: assetPath,
      initialDialogueId: initialDialogueId,
    );

    result.fold(
      (failure) {
        emit(
          DialogueError(message: failure.message),
        );
      },
      (dialogue) {
     
        emit(
          DialogueLoaded(
            currentDialogue: dialogue,
            language: _language,
          ),
        );
      },
    );
  }

  void continueDialogue() {
    log("start continueDialogue method");
    final currentState = state;

    if (currentState is! DialogueLoaded) return;

    final result = dialogueRepo.continueDialogue(
      currentState.currentDialogue.id,
    );

    result.fold(
      (failure) {
        emit(
          DialogueError(message: failure.message),
        );
      },
      (dialogue) {
        emit(
          DialogueLoaded(
            currentDialogue: dialogue,
            language: _language,
          ),
        );
      },
    );
  }

  void selectOption(DialogueOptionEntity option) {
    final currentState = state;

    if (currentState is! DialogueLoaded) return;

    final result = dialogueRepo.selectOption(
      currentDialogueId: currentState.currentDialogue.id,
      option: option,
    );

    result.fold(
      (failure) {
        emit(
          DialogueError(message: failure.message),
        );
      },
      (dialogue) {
        emit(
          DialogueLoaded(
            currentDialogue: dialogue,
            language: _language,
          ),
        );
      },
    );
  }

  void changeLanguage(String language) {
    if (language != 'ar' && language != 'en') return;

    _language = language;

    final currentState = state;

    if (currentState is DialogueLoaded) {
      emit(
        DialogueLoaded(
          currentDialogue: currentState.currentDialogue,
          language: _language,
        ),
      );
    }
  }
}