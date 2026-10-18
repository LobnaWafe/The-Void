import 'package:the_void/features/game/domain/dialogue_entity.dart';

import 'package:dartz/dartz.dart';
import 'package:the_void/features/game/domain/dialogue_option_entity.dart';

class DialogueFailure {
  final String message;

  const DialogueFailure(this.message);
}

abstract class DialogueRepo {
  Future<Either<DialogueFailure, DialogueEntity>> loadDialogues({
    required String assetPath,
    required String initialDialogueId,
  });

  Either<DialogueFailure, DialogueEntity> continueDialogue(
    String currentDialogueId,
  );

  Either<DialogueFailure, DialogueEntity> selectOption({
    required String currentDialogueId,
    required DialogueOptionEntity option,
  });
}