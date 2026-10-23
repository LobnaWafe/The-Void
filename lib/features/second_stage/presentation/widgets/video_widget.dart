
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class VideoWidget extends StatefulWidget {
//   const VideoWidget({
//     super.key,
//     required this.file,
//   });

//   final bool file;

//   @override
//   State<VideoWidget> createState() => _VideoWidgetState();
// }

// class _VideoWidgetState extends State<VideoWidget> {
//   VideoPlayerController? _controller;

//   Future<void> _initializeVideo() async {
//     final videoPath = widget.file
//         ? 'assets/videos/room_second_stage_file.mp4'
//         : 'assets/videos/room_second_stage.mp4';

//     log('Video path: $videoPath');

//     final newController = VideoPlayerController.asset(videoPath);
//     _controller = newController;

//     try {
//       await newController.initialize();

//       if (!mounted || _controller != newController) {
//         await newController.dispose();
//         return;
//       }

//       await newController.setVolume(0);
//       await newController.setLooping(true);
//       await newController.play();

//       if (mounted) {
//         setState(() {});
//       }
//     } catch (error) {
//       debugPrint('تعذر تشغيل فيديو الخلفية: $error');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   @override
//   void didUpdateWidget(covariant VideoWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.file != widget.file) {
//       final oldController = _controller;
//       _controller = null;

//       oldController?.dispose();

//       _initializeVideo();
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = _controller;

//     if (controller == null || !controller.value.isInitialized) {
//       return const SizedBox.expand();
//     }

//     return SizedBox.expand(
//       child: FittedBox(
//         fit: BoxFit.cover,
//         child: SizedBox(
//           width: controller.value.size.width,
//           height: controller.value.size.height,
//           child: VideoPlayer(controller),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({super.key, required this.file});
  final bool file;
  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset(
            widget.file == true
                ? "assets/videos/room_second_stage_file.mp4"
                : 'assets/videos/room_second_stage.mp4',
          )
          ..initialize().then((_) {
            if (!mounted) return;
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
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          : const Center(child: SizedBox()),
    );
  }
}
