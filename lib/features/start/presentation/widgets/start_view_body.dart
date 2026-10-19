import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_void/core/utlis/app_router.dart';
import 'package:video_player/video_player.dart';

class StartViewBody extends StatelessWidget {
  const StartViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: width * 0.13,
        ), // جزء النصوص والأزرار (ياخد 40% من الشاشة)
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The",
                style: GoogleFonts.pixelifySans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              Row(
                children: [
                  SizedBox(width: 36),
                  Text(
                    "Void",
                    style: GoogleFonts.pixelifySans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      
                    ///  GoRouter.of(context).go(AppRouter.gameChatView);
                    GoRouter.of(context).go(AppRouter.firstStageView);
                    },
                    child: Text(
                      "Start",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // جزء الفيديو (ياخد 60% من الشاشة)
        const Expanded(flex: 4, child: VideoWidget()),
      ],
    );
  }
}

class VideoWidget extends StatefulWidget {
  const VideoWidget({super.key});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/game_intro.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: _controller.value.isInitialized
          ? FittedBox(
              fit: BoxFit.cover, // يملى المساحة المخصصة ليه (60%) من غير تشويه
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 150,
                  ),
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(child: SizedBox()),
    );
  }
}
