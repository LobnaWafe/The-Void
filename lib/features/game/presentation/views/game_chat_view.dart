import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/core/utlis/get_it.dart';
import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';
import 'package:the_void/features/game/presentation/widgets/game_chat_view_body.dart';

class GameChatView extends StatelessWidget {
  const GameChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DialogueCubit>()..loadDialogues(),
      child: Scaffold(body: GameChatViewBody()),
    );
  }
}
