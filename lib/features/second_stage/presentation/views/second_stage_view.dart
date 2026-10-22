import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_void/core/utlis/get_it.dart';
import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_cubit.dart';

import 'package:the_void/features/second_stage/presentation/widgets/second_stage_view_body.dart';

class SecondStageView extends StatelessWidget {
  const SecondStageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SecondStageCubit>()..startStage(),
      child: const Scaffold(
        body: SecondStageViewBody(),
      ),
    );
  }
}

