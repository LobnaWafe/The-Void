import 'package:the_void/features/game/data/model/dialogue_option_model.dart';
import 'package:the_void/features/game/domain/dialogue_entity.dart';

class DialogueModel extends DialogueEntity {
  const DialogueModel({
    required super.id,
    required super.speaker,
    required super.text,
    super.nextId,
    super.options,
  });

  factory DialogueModel.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return DialogueModel(
      id: id,
      speaker: json['speaker'] as String,
      text: Map<String, String>.from(json['text'] as Map),
      nextId: json['nextId'] as String?,
      options: (json['options'] as List<dynamic>? ?? [])
          .map(
            (option) => DialogueOptionModel.fromJson(
              Map<String, dynamic>.from(option as Map),
            ),
          )
          .toList(),
    );
  }
}