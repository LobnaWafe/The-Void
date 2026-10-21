import 'package:flutter/material.dart';
import 'package:the_void/features/second_stage/presentation/widgets/second_stage_view_body.dart';


class SecondStageView extends StatelessWidget {
  const SecondStageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SecondStageViewBody(),
    );
  }
}