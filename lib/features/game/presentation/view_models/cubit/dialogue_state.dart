part of 'dialogue_cubit.dart';

@immutable
sealed class DialogueState {}

final class DialogueInitial extends DialogueState {}

final class DialogueLoading extends DialogueState {}

final class DialogueLoaded extends DialogueState {
  final DialogueEntity currentDialogue;
  final String language;

   DialogueLoaded({
    required this.currentDialogue,
    required this.language,
  });

  String get currentText {
    return currentDialogue.text[language] ??
        currentDialogue.text['en'] ??
        '';
  }

  bool get hasOptions => currentDialogue.options.isNotEmpty;

  bool get canContinue => currentDialogue.nextId != null;
}

final class DialogueError extends DialogueState {
  final String message;

   DialogueError({required this.message});
}

