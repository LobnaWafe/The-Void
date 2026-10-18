import 'dialogue_option_entity.dart';

class DialogueEntity {
  final String id;
  final String speaker;
  final Map<String, String> text;
  final String? nextId;
  final List<DialogueOptionEntity> options;

  const DialogueEntity({
    required this.id,
    required this.speaker,
    required this.text,
    this.nextId,
    this.options = const [],
  });
}