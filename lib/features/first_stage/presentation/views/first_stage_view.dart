import 'package:flutter/material.dart';
import 'package:the_void/features/first_stage/presentation/widgets/first_stage_view_body.dart';

class FirstStageView extends StatelessWidget {
  const FirstStageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: 
      FirstStageViewBody()
      ),
    );
  }
}