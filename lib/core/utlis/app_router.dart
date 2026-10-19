import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_void/features/first_stage/presentation/views/first_stage_view.dart';
import 'package:the_void/features/game/presentation/views/game_chat_view.dart';
import 'package:the_void/features/start/presentation/views/start_view.dart';

abstract class AppRouter {
  static final String startView = "/startView";
  static final String firstStageView = "/firstStageView";
  static final String gameChatView = "/gameChatView";

  static final router = GoRouter(
    routes: [
      //  GoRoute(path: "/", builder: (context, state) => SplashView()),
      GoRoute(path: "/", builder: (context, state) => StartView()),
      // GoRoute(
      //   path: "/firstStageView",
      //   builder: (context, state) => FirstStageView(),
      // ),

      GoRoute(
  path:  "/firstStageView",
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const FirstStageView(), // الشاشة اللي هتروحي لها
      transitionDuration: const Duration(milliseconds: 800), // مدة الانيميشن (تقدري تزوديها أو تقلليها)
      reverseTransitionDuration: const Duration(milliseconds: 800), // مدة الانيميشن وقت الرجوع
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // بنستخدم FadeTransition عشان الشاشة تظهر وتختفي تدريجياً (Fade In / Fade Out)
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut, // تباين سلس في بداية ونهاية الحركة
          ),
          child: child,
        );
      },
    );
  },
),


      GoRoute(
  path:  "/gameChatView",
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const GameChatView(), // الشاشة اللي هتروحي لها
      transitionDuration: const Duration(milliseconds: 1000), // مدة الانيميشن (تقدري تزوديها أو تقلليها)
      reverseTransitionDuration: const Duration(milliseconds: 800), // مدة الانيميشن وقت الرجوع
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // بنستخدم FadeTransition عشان الشاشة تظهر وتختفي تدريجياً (Fade In / Fade Out)
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut, // تباين سلس في بداية ونهاية الحركة
          ),
          child: child,
        );
      },
    );
  },
),

    ],

  );


}
