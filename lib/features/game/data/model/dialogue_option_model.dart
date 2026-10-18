import 'package:the_void/features/game/domain/dialogue_option_entity.dart';

class DialogueOptionModel extends DialogueOptionEntity {
  const DialogueOptionModel({
    required super.text,
    required super.nextId,
  });

  factory DialogueOptionModel.fromJson(Map<String, dynamic> json) {
    return DialogueOptionModel(
      text: Map<String, String>.from(json['text'] as Map),
      nextId: json['nextId'] as String,
    );
  }
}