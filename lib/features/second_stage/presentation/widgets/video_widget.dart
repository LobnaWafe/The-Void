import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
    required this.file,
  });

  final bool file;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.file != widget.file) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final videoPath =  'assets/videos/room_second_stage.mp4';
      
    final videoPathWithFile = 'assets/videos/room_second_stage_file.mp4';

    log('Video path: $videoPath');

    final oldController = _controller;
    final newController =widget.file?VideoPlayerController.asset(videoPathWithFile):
     VideoPlayerController.asset(videoPath);

    _controller = newController;

    try {
      await newController.initialize();

      if (!mounted || _controller != newController) {
        await newController.dispose();
        return;
      }

      await newController.setVolume(0);
      await newController.setLooping(true);
      await newController.play();

      oldController?.dispose();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (error) {
      debugPrint('تعذر تشغيل فيديو الخلفية: $error');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (!(_isInitialized && controller != null && controller.value.isInitialized)) {
      return const SizedBox.expand();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

