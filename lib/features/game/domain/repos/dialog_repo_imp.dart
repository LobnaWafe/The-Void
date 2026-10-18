import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:the_void/features/game/data/model/dialogue_model.dart';
import 'package:the_void/features/game/domain/dialogue_entity.dart';
import 'package:the_void/features/game/domain/dialogue_option_entity.dart';
import 'package:the_void/features/game/domain/repos/dialog_repo.dart';


class DialogueRepoImpl implements DialogueRepo {
  Map<String, DialogueEntity> _dialogues = {};

  @override
  Future<Either<DialogueFailure, DialogueEntity>> loadDialogues({
    required String assetPath,
    required String initialDialogueId,
  }) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);

      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final loadedDialogues = jsonMap.map(
        (id, dialogueJson) => MapEntry(
          id,
          DialogueModel.fromJson(
            id,
            Map<String, dynamic>.from(dialogueJson as Map),
          ),
        ),
      );
     log("loadedDialogues ${loadedDialogues.isEmpty}");

      final initialDialogue = loadedDialogues[initialDialogueId];

     // log("${initialDialogue?.nextId ?? "null"}");

      if (initialDialogue == null) {
        return Left(
          DialogueFailure(
            'Dialogue "$initialDialogueId" was not found.',
          ),
        );
      }

      _dialogues = loadedDialogues;
      
      log("return right");
      return Right(initialDialogue);
    } catch (error) {
       log("return left");
      return Left(
        DialogueFailure(
          'Failed to load dialogues: $error',
        ),
      );
    }
  }

  @override
  Either<DialogueFailure, DialogueEntity> continueDialogue(
    String currentDialogueId,
  ) {
    final currentDialogue = _dialogues[currentDialogueId];

    if (currentDialogue == null) {
      return Left(
        DialogueFailure(
          'Dialogue "$currentDialogueId" was not found.',
        ),
      );
    }

    final nextId = currentDialogue.nextId;

    if (nextId == null) {
      return Left(
        const DialogueFailure(
          'There is no next dialogue.',
        ),
      );
    }

    final nextDialogue = _dialogues[nextId];

    if (nextDialogue == null) {
      log("Dialogue was not found.");
      return Left(
        DialogueFailure(
          'Dialogue "$nextId" was not found.',
        ),
      );
    }

    return Right(nextDialogue);
  }

  @override
  Either<DialogueFailure, DialogueEntity> selectOption({
    required String currentDialogueId,
    required DialogueOptionEntity option,
  }) {
    final currentDialogue = _dialogues[currentDialogueId];

    if (currentDialogue == null) {
      return Left(
        DialogueFailure(
          'Dialogue "$currentDialogueId" was not found.',
        ),
      );
    }

    if (!currentDialogue.options.contains(option)) {
      return Left(
        const DialogueFailure(
          'The selected option does not belong to this dialogue.',
        ),
      );
    }

    final nextDialogue = _dialogues[option.nextId];

    if (nextDialogue == null) {
      return Left(
        DialogueFailure(
          'Dialogue "${option.nextId}" was not found.',
        ),
      );
    }

    return Right(nextDialogue);
  }
}