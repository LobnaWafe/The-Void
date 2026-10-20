import 'dialogue_option_entity.dart';

class DialogueEntity {
  final String id;
  final String speaker;
  final Map<String, String> text;
  final String? nextId;
  final String? expression;
  final List<DialogueOptionEntity> options;
  final String? action;

  const DialogueEntity({
    required this.id,
    required this.speaker,
    required this.text,
    this.nextId,
    this.options = const [],
     this.expression, this.action,
  });
}