
import 'package:flutter/material.dart';
import 'package:the_void/features/game/domain/dialogue_entity.dart';
import 'package:the_void/features/game/domain/dialogue_option_entity.dart';
import 'package:the_void/features/game/presentation/widgets/player_options.dart';

class OptionsListWidget extends StatelessWidget {
  const OptionsListWidget({
    super.key,
    required this.height,
    required this.dialogue,
    required this.language,
  });

  final double height;
  final DialogueEntity dialogue;
  final String language;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = height * 0.4;
        final maxRows = (maxHeight / 55).floor().clamp(1, 10);
    
        final options = dialogue.options;
        final columns = <List<DialogueOptionEntity>>[];
    
        for (int i = 0; i < options.length; i += maxRows) {
          final end = (i + maxRows).clamp(0, options.length);
          columns.add(options.sublist(i, end));
        }
    
        return SizedBox(
          height: maxHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns.map((column) {
              return Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: column.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: PlayerOptions(
                        option: option,
                        language: language,
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
